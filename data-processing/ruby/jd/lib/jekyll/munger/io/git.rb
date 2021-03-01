require_relative '../../difasia.rb'
require 'git'
require 'fileutils'

class TestReader < RuntimeSupport
  def initialize(driver,config)
    debug "Constructed TestReader #{config.inspect}"
    @config = config
    @driver = driver
  end

  def files()
    @files
  end

  def obtain_and_stamp()
    debug "Obtain and stamp #{@driver.inspect} "
    @files = []
    nil
  end
  def load()
    debug "Load"
    []
  end
end

class TestWriter < RuntimeSupport
  def initialize(config,pool = nil)
    @pool = pool
    debug "Constructed Writer #{config.inspect}"
  end

  def write(directory)
    files_written = []

    files_written
  end
end

class GitController < AbstractController
  def initialize(config)
    super(config)
    debug "Built GitController, config=#{config.inspect}"
  end


end
