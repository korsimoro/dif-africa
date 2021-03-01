require "jekyll/difasia/version"

module Jekyll
  module Difasia
    class Error < StandardError; end
    # Your code goes here...
  end
end

require_relative './data/database.rb'

class GlobalDatabase < RuntimeSupport
  attr_reader :sources, :sinks, :site, :dblist, :models, :basedir
  attr_accessor :schedule, :countries
  def initialize(site,dblist = [])
    @site = site
    @dblist = dblist
    config = site.config['difasia']
    @sources = config['sources']
    @sinks = config['sinks']
    @models = {}

    @basedir = File.join(@site.source,"..")

    config['models'].each do |key,config|
      info "Model: #{key}, #{config}"
      defn = YAML.load_file(File.join(@basedir,'data-processing','schemas',key+'.yml'))
      schema = SchemaEntry.new(key,defn)
      @models[key] = schema
      if dblist.include? key
        klass = Class.new(Node)
        klass.class_eval do
          @@schema = nil
          def self.schema
            @@schema
          end
          def self.schema=(value)
            @@schema = value
          end
        end
        klass.schema = schema
        self.send("#{key}=", Database.new(key,self,klass) )
      end
    end

  end

end

require "jekyll/commands/hello.rb"
require "jekyll/commands/fix_schedule.rb"
require "jekyll/commands/munge.rb"
