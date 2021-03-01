require_relative './yaml.rb'
require_relative './notion.rb'
require_relative './collection.rb'
require_relative './kumu.rb'
require_relative './runtime.rb'
require_relative './node.rb'
require 'date'
require 'securerandom'

class FieldDatum
  def initialize(key,defn)
    @key = key
    @index = defn['index']
    @flavors = {}
    flavormap=defn['flavors']
    @default_name = flavormap['_']
    RecordPool.flavor_suite.each do |f|
      @flavors[f] = flavormap[f] ? flavormap[f] : @default_name
    end
  end
  attr_reader :names, :default_name, :key, :index, :flavors
end

class EncounterRecord < RuntimeSupport

  @guid = nil
  def guid
    @guid
  end
  def guid=(value)
    @guid = value
    self.map_self_into_hashes()
  end

  def initialize(flavor,hash)
    @flavor = flavor
    @hash = hash
    self.map_hash_into_self(yaml)
  end

  attr_reader :hashes

  def [](key)
    result = @hashes[0][key]
    #puts "LOOK UP "+key.inspect+" => "+result.inspect
    result
  end
  def []=(key,value)
    @hashes.each do |hash|
      hash[key]=value
    end
    self.map_hash_into_self(@hashes[0])
  end

  def map_hash_into_self(hash)
    info self.class.inspect
    @@schema.fields.each do |key,prop_name|
      self.send("#{prop_name}=",hash[key])
    end
    #self.instance_variable_set(prop_name, value)

  end


  def map_self_into_hashes()
    @hashes.each do |hash|
      @@schema.fields.each do |key,prop_name|
        @hash[key] = self.get_attribute_by_name(prop_name)
      end
    end
  end


  def merge(another)
    merge = []
    @@schema.fields.each_key do |field|
      #puts field.inspect
      #puts "Guid".inspect
      a = self.hashes[0][field]
      b = another.hashes[0][field]
      if a != b
        merge << field
      end
    end

    if merge.length > 0
      info "Differences in fields "+merge.inspect
    else
      debug "No Differences "+self.label.inspect
    end

    #puts another.hashes[0].inspect
    #puts self.hashes[0].inspect
    #puts another.hashes[0]["Guid"].inspect
    #puts self.hashes[0]["Guid"].inspect
    @@schema.fields.each_key do |field|
      #puts field.inspect
      #puts "Guid".inspect
      a = self.hashes[0][field]
      b = another.hashes[0][field]
      if a != b
        if b
          debug "SETTING MY "+field+" to ANOTHER:"+b.inspect
          self[field] = b
        end
        if a
          debug "SETTING ANOTHER "+field+" to MY:"+a.inspect
          another[field] = a
        end
      end
    end
    self.hashes << another.hashes
    self.map_hash_into_self(self.hashes[0])
    #raise "damn it"
  end

  def matches?(another)
    puts("\nTesting for match:"+self.inspect+"::"+another.inspect)
    @guid == another.guid or @label == another.label
  end


  def topic_markdown()
    "Topic Markdown"
    raise
  end

end


class Record

  def guid
    @reference_hash['guid']
  end
  def guid=(value)
    @reference_hash['guid'] = value
  end

  def initialize()
    @reference_hash = {}
  end

  def [](key)
    result = @reference_hash[key]
    #puts "LOOK UP "+key.inspect+" => "+result.inspect
    result
  end
  def []=(key,value)
    @reference_hash[key]=value
  end

end

class Encounter
  def initialize(flavor,hash)
    @records
  end

end

# define a set of records of a specific 'type'
class RecordPool < RuntimeSupport
  @@flavor_suite = ['notion','csv','collection','kumu']
  def self.flavor_suite()
    @@flavor_suite
  end
  @@basedir = ['notion','csv','collection','kumu']
  def self.basedir()
    @@basedir
  end
  def self.basedir=(value)
    @@basedir = value
  end

  def initialize(key)

    @key = key
    @indices = []
    @fields = {}
    @flavors = {}

    # load the schema
    debug "Load schema for #{key}"
    defn = YAML.load_file(File.join(@@basedir,'data-processing','schemas',key+'.yml'))
    defn.each do |field,config|
      fd = FieldDatum.new(field,config)
      @fields[field] = fd
      # look for indices
      if fd.index
        @indices << field
      end
    end

    @@flavor_suite.each do |flavor|
      inbound = {}
      outbound = {}
      @fields.each do |key,fd|
        fd_name = fd.flavors[flavor]
        outbound[key] = fd
        inbound[fd_name] = fd
      end
      @flavors[flavor] = [inbound,outbound]
    end

    # set up indexing
    @index_map = {}
    @no_index_map = {}

    @indices.each do |index|
      @index_map[index] = {}
      @no_index_map[index] = []
    end

    @guid_map = @index_map['guid']
    @no_guids = @no_index_map['guid']
  end


  # For each index, look in the corresponding index and determine if this
  # represents either:
  #   - an object missing that index
  #   - a 2nd occurance of an entity
  #   - a new entity
  #
  def integrate(entity)
    @index_map.each do |index_key,index|
      value = entity.instance_variable_get("@#{index_key}")
      if value
        other = index[value]
        if other
          debug "MERGING:#{index_key} = #{value}"
          other.merge(entity)
        else
          debug "INDEXING:#{index_key} = #{value}"
          index[value] = entity
        end
      else
        debug "Object has no value for :#{index_key}, adding to missing link: inpsect->"+entity.inspect
        @no_index_map[index_key] << entity
      end
    end
  end

  # encounter a hash from a specific flavor
  def receive_hash(flavor,hash)
    inbound,outbound = @flavors[flavor]

    object_template = Record.new()
    hash.each_pair do |key,value|
      field_def = inbound[key]
      if field_def
        object_template[field_def.key]=value
        debug "Setting #{field_def.key} from #{key}"
      else
        raise "Missing field def for #{key}"
      end
    end

    match = self.locate(object_template)
    if match
      debug "Found"
    else
      debug "new object, indexing"
      @index_map.each do |index_key,index|
        val = object_template[index_key]
        debug "val for #{index_key} is #{val}, index=#{index}"
        index[val] = object_template
      end
    end

    match = self.locate(object_template)

    raise "Abort"
  end

  def locate(obj)
    matches = []
    match = nil
    match_index = nil
    @indices.each do |index|
      found = locate_by_index(index,obj)
      if found
        if match
          if match != found
            debug "Multiple Index / Multiple Object - Collision"
            matches << found
          else
            debug "Multiple Index Match - same object, all good"
          end
        else
          debug "First Match"
          match = found
          match_index = index
          matches << found
        end
      else
        # not found, and no match
        if match
          debug "Not on index #{index} - w/ previous match (MI=#{match_index})"
        else
          debug "Not on index #{index} and no previous match"
        end
      end
    end
    if matches.length > 0
      if matches.length == 1
        matches[0]
      else
        raise "Multiple Match Error: #{matches.inspect}"
      end
    else
      nil
    end
  end

  def locate_by_index(index,obj)
    idx = @index_map[index]
    if ! idx
      raise "Missing index #{index}"
    end

    probe_value = obj[index]
    if probe_value
      debug "Attempting Locate By Index, index=#{index}, pv=#{probe_value}"
      result = idx[probe_value]
      if result
        debug "Located #{result.inspect}"
        result
      end
    end
  end

  def dump()
    debug "Record Pool: #{@key}"
    debug @fields.inspect
    debug @flavors.inspect
  end

end





def class_from_string(str)
  str.split('::').inject(Object) do |mod, class_name|
    mod.const_get(class_name)
  end
end

class DatabaseSupport < RuntimeSupport
  def initialize(indices = [])
    @indices = indices
    @indices << 'guid'

    @index_map = {}
    @no_index_map = {}

    @indices.each do |index|
      @index_map[index] = {}
      @no_index_map[index] = []
    end

    @guid_map = @index_map['guid']
    @no_guids = @no_index_map['guid']
  end


  def attach(entity)
    @index_map.each do |index_key,index|
      value = entity.instance_variable_get("@#{index_key}")
      if value
        other = index[value]
        if other
          debug "MERGING:#{index_key} = #{value}"
          other.merge(entity)
        else
          debug "INDEXING:#{index_key} = #{value}"
          index[value] = entity
        end
      else
        debug "Object has no value for :#{index_key}, adding to missing link: inpsect->"+entity.inspect
        @no_index_map[index_key] << entity
      end
    end
  end

end


class Database < RuntimeSupport
  def initialize(key,global,type,indices = [])
    site = global.site
    config = global.sources[key]
    name = config['name']
    guid = config['guid']
    @indices = indices
    @indices << 'guid'

    @notion = NotionDatabase.new(site,name,guid)
    @yaml = YamlFileDatabase.new(site,File.join('dif',key),'guid')
    @collection = CollectionDatabase.new(site,key)

    self.initialize_guid_map()

    self.load_collection_into_map(type)
    self.load_notion_into_map(type)
    self.load_yaml_into_map(type)

    self.rectify_no_guids()
  end

  attr_reader :yaml, :notion, :no_guids

  def save()
    @guid_map.each do |key,value|
      debug "Storing #{key} -> #{@yaml.data}"
      @yaml.data[key] = value.to_yaml
    end
    @yaml.save()
  end

  def initialize_guid_map()
    @index_map = {}
    @no_index_map = {}
    @indices.each do |index|
      @index_map[index] = {}
      @no_index_map[index] = []
    end
    @guid_map = @index_map['guid']
    @no_guids = @no_index_map['guid']
  end

  def rectify_no_guids()
    new_no_guids = []
    merge = false
    @no_guids.each do |ng|
      puts("Exploring GUIDLESS:"+ng.inspect)
      if !self.find_match_for_guidless_and_merge(ng)
        puts("CREATE NEW GUID "+ng.inspect)
        ng.guid = SecureRandom.uuid
        self.attach(ng)
      end
      merge = true
    end
    if merge
      self.yaml.save()
    end
  end

  def find_match_for_guidless_and_merge(ng)
    found = false
    @guid_map.each do |key,entry|
      if self.matches?(entry,ng)
        debug "FOUND MATCH"
        self.merge(entry,ng)
        found = true
        break
      end
    end
    found
  end

  def matches?(a,b)
    a.matches?(b)
  end
  def merge(a,b)
    a.merge(b)
  end

  def fully_integrated?()
    @no_guids.length() == 0
  end

  def attach(entity)
    @index_map.each do |index_key,index|
      value = entity.instance_variable_get("@#{index_key}")
      if value
        other = index[value]
        if other
          debug "MERGING:#{index_key} = #{value}"
          other.merge(entity)
        else
          debug "INDEXING:#{index_key} = #{value}"
          index[value] = entity
        end
      else
        debug "Object has no value for :#{index_key}, adding to missing link: inpsect->"+entity.inspect
        @no_index_map[index_key] << entity
      end
    end
  end

  def load_yaml_into_map(type)
    @yaml.data.each do |data|
      entity = type.new(data)
      self.attach(entity)
    end
  end

  def load_notion_into_map(type)
    @notion.files.each do |file|
      entity = type.new(file.values)
      debug "Loaded Entity with NOTION LINK IS:"+entity["Notion Link"].inspect
      self.attach(entity)
    end
  end
  def load_collection_into_map(type)
    @collection.files.each do |file|
      entity = type.new(file.values)
      debug "Loaded Entity with NOTION LINK IS:"+entity["Notion Link"].inspect
      self.attach(entity)
    end
  end

end
