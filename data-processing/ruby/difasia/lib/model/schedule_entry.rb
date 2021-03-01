require_relative './database.rb'

class ScheduleEntry < AbstractEntry
  def initialize(yaml)
    fields = {
      "Guid" => 'guid',
      'Name' => 'name',
      'Notion Link' => 'agenda',
      'Business' => 'business',
      'Country Spotlight' => 'country',
      'Events' => 'events',
      'Legal' => 'legal',
      'Responsibility':"responsibility",
      'Social' => 'social',
      'When' => 'when'
    }
    super(yaml,fields)
  end

  attr_accessor :guid, :name, :business, :country, :events, :legal, :responsibility, :social, :when, :agenda

end

class ScheduleEntry2
  def initialize(yaml)
    @hashes = [ yaml ]
    @fields = {
      "Guid" => 'guid',
      'Name' => 'name',
      'Notion Link' => 'agenda',
      'Business' => 'business',
      'Country Spotlight' => 'country',
      'Events' => 'events',
      'Legal' => 'legal',
      'Responsibility':"responsibility",
      'Social' => 'social',
      'When' => 'when'
    }
    self.map_hash_into_self(yaml)
  end

  attr_accessor :guid, :name, :business, :country, :events, :legal, :responsibility, :social, :when, :hashes, :agenda

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
    @fields.each do |key,prop_name|
      self.send("#{prop_name}=",hash[key])
    end
    #self.instance_variable_set(prop_name, value)

  end

  def map_back()
    @hashes.each do |hash|
      @fields.each do |key,prop_name|
        @hash[key] = self.get_attribute_by_name(prop_name)
      end
    end
  end

  def merge(another)
    puts "I HAVE BEEN ASKED TO MERGE"
    #puts another.hashes[0].inspect
    #puts self.hashes[0].inspect
    #puts another.hashes[0]["Guid"].inspect
    #puts self.hashes[0]["Guid"].inspect
    @fields.each_key do |field|
      #puts field.inspect
      #puts "Guid".inspect
      a = self.hashes[0][field]
      b = another.hashes[0][field]
      puts "MERGING FIELD "+field.inspect+":"+a.inspect+":"+b.inspect
      if a != b
        if b
          puts "SETTING FIELD "+field+" to "+b.inspect
          self[field] = b
        end
        if a
          puts "SETTING FIELD "+field+" to "+a.inspect
          another[field] = a
        end
      end
    end
    self.hashes << another.hashes
    self.map_hash_into_self(self.hashes[0])
    #raise "damn it"
  end
  def matches?(another)
    @name == another.name
  end


  def topic_markdown()
    "Topic Markdown"
    raise
  end

end
