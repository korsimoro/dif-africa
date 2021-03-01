require_relative '../difasia.rb'
require_relative '../data/csv.rb'
require_relative '../data/yaml.rb'
require 'git'
require 'fileutils'
require_relative './io/index.rb'
require_relative './ontology.rb'
require_relative './assessment.rb'


class Munger < RuntimeSupport
  def initialize(site)
    @site = site

    @gitworm_dir = File.join(site.source,'..','gitworm') # directory that is the base of the gitworm
    @munge_config = YAML.load_file(File.join(@gitworm_dir,'mungeconfig.yml')) # read .munge_config
    @munge_arena = File.join(@gitworm_dir,'arena')
    @munge_cache = File.join(@gitworm_dir,'cache')

    # a map of the core entity schema and representational flavors
    @ontology = MungeOntology.new(@munge_config['ontology'])

    # a service oriented mapping of readers and writers, bound to
    # the consumption of 'flavored' inputs via "I accept"
    @io = MungeIO.new(@munge_config['io'])
  end

  def initialize_record_pool_engine()
    rp = RecordPoolEngine.new
    info "Record Pool Engine Initialized"
    rp
  end

  # establish a reference graph of the data 'as it is known' at the start
  # of the munge.  this clones a git url (e.g. file tree at a point) and
  # loads it into a common, living, graph representation based on the
  # data model.
  #
  # A> make a temporary directory and store the name for cleanup
  # B> clone the repository at a given commit
  # C> read the data, following the RecordPool flavor conventions
  # .... notion-html> Result of Notion HTML (see: whitespace trouble w/ CSV)
  # .... notion-api> Result of Notion API (not yet available)
  # .... google-sheet> Result of Google Sheet Dump
  # .... google-kumu> Google Sheet Coupled with Google
  # .... repo-csv> CSV
  # .... repo-yml> YML
  # .... repo-md-files> Jekyll Collection?
  # .... tiddly> Aye, or nay?
  #
  def clone_and_load_munge_arena

    # Establish active Git control over a directory, rooted at a specific commit
    # from a repository.  This is the effective 'trust root' - it is an instance
    # of a repository that fits into pretty much all software tools, natively.
    authority_config = @munge_config['authority']
    repo_url = authority_config['url']
    info "Prepare working area at #{@munge_arena} with clone from #{repo_url}"
    FileUtils.rm_rf(@munge_arena)
    @arena_git = Git.clone(repo_url, @munge_arena, :log => Logger.new(STDOUT))
    FileUtils.rm_rf(@munge_cache)
    FileUtils.mkdir_p(@munge_cache)

    # make sure we have clean record pool engine (RPE), and maybe a little metadata
    # to anchor the provenance chain.  The RPE is bound to a private key, so
    # actions it takes are provenance anchored against control of that key.
    @record_pool_engine = self.initialize_record_pool_engine

    # now build a map of the pools from the config, figuring out what files
    # in the arena match the trigger globs and then running them through the
    # ingress/digestion process.  We cache the PoolDriver in the @pools map
    # anticipating use of these PoolDrivers to know how to also 'write' any
    # changed records.
    @pools = {}
    pool_config = authority_config['pools']
    pool_config.each do |config|
      name = config['name']

      info "Attaching #{name} pool to RPE and registering driver"
      driver = PoolDriver.new(name,config,@record_pool_engine)
      @pools[name] = driver

      Dir.glob(driver.globs).each do |path|
        debug "Loading Path For Pool #{name}, path=#{path}"
        driver.load(path)
      end

    end

  end
  def cleanup
    # A> clean up directoriy
  end

  def internalize_representation(context)
    reader = context[:reader]

    if reader != nil
      info "Internalizing Representation context=#{context.inspect}"

      # obtain a copy of the data from a source and stamp its arrival, this is
      # the copy that will be used to load.  Loading consists of traversing
      # the cache and emitting a series of assertions - in the form of objects.
      status = reader.obtain_and_stamp
      if status == nil
        reader.load.each do |element|
          self.overlay(element)
        end
      else
        raise "Status:"+status.inspect
      end
    end
  end

  # incorporate an element into this data pool
  def overlay(element)
    debug "Overlay element"
  end

  def assess_munge_arena(context)
    reader = context[:reader]
    writer = context[:writer]
    files_to_delete = reader == nil ? [] : reader.files

    info "assess_munge_arena: Writing Files, starting deletion list #{files_to_delete}"
    writer.write(@munge_arena).each do |file|
      files_to_delete.remove(file)
    end
    files_to_delete.each do |file|
      writer.remove(file)
    end

    # calculate diff
    debug "Calculating Diff"
    stats = [] #@git.diff(@munge_arena)

    Assessment.new(stats)
  end

  def obtain_curatorial_commitment
    info "obtain_curatorial_commitment"
  end

  def update_munge_arena
    info "update_munge_arena"
  end

  def externalize_representation(context)
    info "externalize_representation: #{context.inspect}"
  end

  def report_success(summary)
    info "Report Success: #{summary.inspect}"
  end

  def report_conflict(summary)
    info "Report Conflict: #{summary.inspect}"
  end

  def report_abort(summary)
    info "Report Abort: #{summary.inspect}"
  end

  def reset_munge_arena
    info "reset_munge_arena"
  end

  def publish_munge_arena
    info "publish_munge_arena"
  end

  def munge()
    # establish a reference graph of the data 'as it is known' at the start
    # of the munge.  this clones a git url (e.g. file tree at a point) and
    # loads it into a common, living, graph representation based on the
    # data model.
    self.clone_and_load_munge_arena

    # now, for each 'representation' of the data, load it in turn - do a
    # blind, overlay merge.  Then look at the diff generated by that overlay
    # and trigger a content analysis.  If there are resolvable changes, then
    # the change is integrated and pushed up
    @munge_config['representations'].each do |representation_config|
      key = representation_config['key']
      debug "Processing Representation #{key} - Config is #{representation_config.inspect}"
      context = {
        :key => key,
        :reader => @io.create_reader(representation_config),
        :writer => @io.create_writer(representation_config)
      }
      debug "Processing Representation #{key} - Context is #{context.inspect}"

      # go out and 'get' data from a source - using the internalization
      # engine to receive new assertions of data.  This is additive and
      # destructive, as the delta is non-commutative.
      self.internalize_representation(context)

      # write the data out in a canonical fashion (the same one read by
      # clone_and_load_munge_arena) - the 'git diff' will provide the integrated
      # control system for managing the arena
      assessment = self.assess_munge_arena(context)

      # if the assessment is conflict free and the operating context allows it,
      # then update the central munge arena, and update the target representation
      # so that this 'touch' includes a read, integration, and broadcast - you
      # only ever update after you've listened fully.
      if assessment.conflict_free?
        if self.obtain_curatorial_commitment
          self.update_munge_arena
          self.externalize_representation(context)
          self.report_success(assessment.summary)
        else
          self.report_abort(assessment.summary)
          self.reset_munge_arena
        end
      else
        self.report_conflict(assessment.summary)
        self.reset_munge_arena
      end
    end

    # push upstream and trigger any data-change driven workflows.
    self.publish_munge_arena

  end

end
