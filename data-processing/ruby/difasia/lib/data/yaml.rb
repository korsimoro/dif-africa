require 'yaml'
require 'date'

class YamlFileDatabase
  def initialize(site,file)
    @site = site
    @path = File.join(site.source,'_data',file + '.yml')
    @data = YAML.load_file(@path)
  end

  def save()
    File.open(@path, "w") { |file| file.write(@data.to_yaml) }
  end

  attr_reader :site, :data, :path

end

class SourcesFile < YamlFileDatabase
  def initialize(site)
    super(site,'sources')
    @schedule = @data['notion']['raw']['schedule']
  end

  attr_reader :data

  def read_schedule_last_update()
    date_str = @schedule['processed']
    if date_str
      Date.parse(date_str)
    end
  end
  def record_schedule_update()
    @schedule['processed'] = Date.today.to_s
    self.save
  end
end
