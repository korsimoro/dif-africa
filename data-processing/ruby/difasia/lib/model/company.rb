class Company

  def self.new_from_link(link)
    /(?<prefix>https:\/\/www.notion.so\/?)(?<name>.*)-(?<guid>[0-9a-fA-F]*)/ =~ link
    self.new(prefix,name,guid)
  end

  def initialize(prefix,name,guid)
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
