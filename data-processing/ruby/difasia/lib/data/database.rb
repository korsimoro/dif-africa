require_relative './yaml.rb'
require 'date'
require 'uuid'

class Database
  def initialize(sources,key,entity)
    name = sources.data[key]['name']
    guid = sources.data[key]['guid']

    @yaml = YamlFileDatabase.new(sources.site,name)
    @notion = NotionDatabase.new(sources.site,name,guid)
    self.initialize_guid_map()
    self.load_yaml_into_guid_map(entity)
    self.load_notion_into_guid_map(entity)
    self.rectify_no_guids()
    #self.yaml.save()
    puts "I DID IT"
  end

  attr_reader :yaml, :notion, :no_guids

  def initialize_guid_map()
    @guid_map = {}
    @no_guids = []
    @index_map = {}
    @index_map['guid'] = @guid_map
  end

  def rectify_no_guids()
    new_no_guids = []
    merge = false
    @no_guids.each do |ng|
      if !self.find_match_for_guidless(ng)
        ng.guid = uuid.new()
        self.attach(ng)
      end
      merge = true
    end
    if merge
      self.yaml.save()
    end
  end

  def find_match_for_guidless(ng)
    found = false
    @guid_map.each do |key,entry|
      if self.matches?(entry,ng)
        puts "FOUND MATCH"
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
    guid = entity.guid
    if guid
      if @guid_map[guid]
        @guid_map[guid].merge(entity)
      else
        @guid_map[guid] = entity
      end
    else
      @no_guids << entity
    end
  end

  def load_yaml_into_guid_map(type)
    @yaml.data.each do |data|
      entity = type.new(data)
      self.attach(entity)
    end
  end

  def load_notion_into_guid_map(type)
    @notion.files.each do |file|
      entity = type.new(file.values)
      puts entity["Notion Link"].inspect
      self.attach(entity)
    end
  end

end
