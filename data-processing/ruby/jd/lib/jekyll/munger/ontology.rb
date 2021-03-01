require_relative '../difasia.rb'
require_relative '../data/csv.rb'
require_relative '../data/yaml.rb'
require 'git'
require 'fileutils'


class MungeOntology < RuntimeSupport
  # see database.rb right now
  def initialize(config)
    debug config.inspect
  end

end

class PoolDriver < RuntimeSupport
  def initialize(name,config,rpe)
    debug "Configuring PoolDriver #{name} with config = #{config.inspect}"
    @glob = config['glob']
    @record_pool_engine = rpe
  end

  def globs()
    [ @glob ]
  end

  def load(path)
    debug "Loading data from Path #{path}"
  end
end

class RecordPoolEngine
  # see database.rb right now
end
