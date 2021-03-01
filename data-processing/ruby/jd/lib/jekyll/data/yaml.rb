require 'yaml'
require 'date'

require_relative './runtime.rb'

class YamlFileDatabase < RuntimeSupport
  #include RuntimeSupport
  def initialize(site,file,record_pool)
    @site = site
    @record_pool = record_pool
    @path = File.join(site.source,'_data',file + '.yml')
    File.open(@path, "a") { }
    @data = YAML.load_file(@path)
    if ! @data
      if @index == nil
        @data = []
      else
        @data = {}
      end
      self.save()
    else
      @data.each do |record|
        debug record.inspect
      end
    end
    debug "Loaded "+@path+" and got "+@data.inspect
  end

  def save()
    warn "Writing #{@path} : "+@data.to_yaml
    File.open(@path, "w") { |file| file.write(@data.to_yaml) }
  end

  attr_reader :site, :data, :path, :index

end
