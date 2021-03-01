
require_relative './runtime.rb'
require 'date'

# Node is container that consists of a set of key=value fields, along with
# a free form data body.  Nodes conform to a schema, and may have links to
# other objects.  Every Node has two unique indices, a guid and a name slug.
#
# A Node may be rendered as multiple formats, and it may be reconstituted
# from multiple formats.
#
#
#

class Node < RuntimeSupport

#  @@schema = nil
#  def self.schema
#    @@schema
#  end
#  def self.schema=(value)
#    @@schema = value
#  end

  @guid = nil
  def guid
    @guid
  end
  def guid=(value)
    @guid = value
    self.map_self_into_hashes()
  end

  @label = nil
  def label
    @label
  end
  def label=(value)
    @label = value
    self.map_self_into_hashes()
  end



  def initialize(yaml)
    @hashes = [ yaml ]
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
