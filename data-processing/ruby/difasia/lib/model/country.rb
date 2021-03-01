require_relative './database.rb'

class Country < AbstractEntry
  def initialize(yaml)
    super(yaml,{
      'Guid' => 'guid'
      })
  end

  attr_accessor :guid

  def new_from_link(link)
    /(?<prefix>https:\/\/www.notion.so\/?)(?<name>.*)-(?<guid>[0-9a-fA-F]*)/ =~ link
    self.new(prefix,name,guid)
  end

  def old_initialize(prefix,name,guid)
    @prefix = prefix
    @name = name
    @slug = Jekyll::Utils.slugify(name)
    @label = name.gsub("-"," ")
    @guid = guid
  end

  def as_string()
    @prefix + @name + "-" + @guid
  end



end
