require 'yaml'
require 'csv'
require_relative './database.rb'

class CSVRow
  def initialize(index,hash)
    @index = index
    @hash = hash
  end
end

class CSVDatabase < DatabaseSupport
  def initialize(site,name)
    super()
    basedir = File.join(site.source,'..','data-processing','scopes','repo')
    @csv = File.join(basedir,name + '.csv')

    @data = CSV.read(@csv, headers:true, return_headers:true) # <CSV::Table mode:col_or_row row_count:1>
    @headers = @data.headers # => ["Day", "Time"]
    skip = true
    @count = 0
    @rows = []
    @data.each do |row|
      if skip
        skip = false
      else
        @rows[@count] = CSVRow.new(@count,row)
        @count = @count + 1
      end
    end
  end
  attr_reader :path, :guid, :name, :csv, :dir, :files


  def save()
    CSV { }
    Dir.each_child(@dir) do |filename|
      @files << CSVRow.new(filename,@dir)
    end
  end

end
