require_relative '../difasia.rb'
require_relative '../data/csv.rb'
require_relative '../data/yaml.rb'

def do_thing(site)
  rp = RecordPool.new('schedule')
  rp.dump
  yaml = YamlFileDatabase.new(site,"schedule",rp)
  info = YAML.load_file(File.join(site.source,'_data','Schedule.yml'))
  info.each do |elt|
    rp.receive_hash('notion',elt)
  end
  puts info.inspect

  CSVDatabase.new(site,'companies')
end

module Jekyll
  module Commands
    class FixSchedule < Command
      class << self
        def init_with_program(prog)
          prog.command(:fix_schedule) do |c|
            c.syntax      "build [options]"
            c.description "Fix site"

            #add_build_options(c)
            # Adjust verbosity quickly
            c.option "verbose", "-V", "--verbose", "Print verbose output."

            c.action do |args, options|
              Jekyll.logger.adjust_verbosity(options)

              Jekyll.logger.info "Fix_Schedule!"+args.inspect+":"+options.inspect

              options = configuration_from_options(options)
              site = Jekyll::Site.new(options)
              RecordPool.basedir = File.join(site.source,'..')

              do_thing(site)
              raise "Done"

              begin
                munge_data(site)
              rescue => exception
                puts exception.backtrace
                raise # always reraise
              end
            end
          end
        end

        def munge_data(site)
          # create a global database and add types to it
          global = GlobalDatabase.new(site,['schedule','country'])
          schedule = global.schedule
          if schedule.fully_integrated?
            puts "Yeah"
          else
            schedule.no_guids.each do |x|
              puts x.name
            end
            raise "Found some elements that did not have GUIDs"
          end

          schedule.save()
        end

      end
    end
  end
end



#def run_hook(site)
#  puts "Loading Schedule and Updating YAML"
#  # code to call after Jekyll renders a page
#  sources = SourcesFile.new(site)
#  schedule = ScheduleDatabase.new(sources)
#  if schedule.fully_integrated?
#    puts "Yeah"
#  else
#    puts "Found some elements that did not have GUIDs"
#    schedule.no_guids.each do |x|
#      puts x.name
#    end
#  end
#  #schedule.yaml.save()
#end
#
#Jekyll::Hooks.register :site, :post_read do |site|
#
#  #require 'httplog' # require this *after* your HTTP gem of choice
#  begin
#    run_hook(site)
#  rescue => exception
##    raise # always reraise
#  end
#end
