require_relative '../../difasia.rb'
require 'git'
require 'fileutils'

# a service oriented mapping of readers and writers
class MungeIO < RuntimeSupport


  def initialize(config)
    @drivers = {}

    info "Configuring MungeIO - connections between munge arena and external"
    config.each do |key,service_config|
      classname = service_config['class']
      clazz = classname.split('::').inject(Object) { |o,c| o.const_get c}
      debug "Loading IO Driver for #{key} -> #{service_config}, class=#{clazz}"
      @drivers[key] = clazz.new(service_config)
    end
  end

  def create_reader(config)
    driver_name = config['driver']
    driver = @drivers[driver_name]
    driver.create_reader(config)
  end

  def create_writer(config)
    driver_name = config['driver']
    driver = @drivers[driver_name]
    driver.create_writer(config)
  end

end



class AbstractController < RuntimeSupport
  def initialize(config)
    debug "Built AbstractController, config=#{config.inspect}"
    @config = config
    reader_classname = config['reader']
    if reader_classname != nil
      @reader_class = reader_classname.split('::').inject(Object) { |o,c| o.const_get c}
    end

    writer_classname = config['writer']
    if writer_classname != nil
      @writer_class = writer_classname.split('::').inject(Object) { |o,c| o.const_get c}
    end
  end


  def create_reader(config)
    if @reader_class != nil
      @reader_class.new(self,config)
    end
  end

  def create_writer(config)
    if @writer_class != nil
      @writer_class.new(self,config)
    end
  end

end

require_relative "./git.rb"
