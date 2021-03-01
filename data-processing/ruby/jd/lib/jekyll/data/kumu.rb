require 'yaml'
require 'date'

class KumuMarkdownFile
  def initialize(guid,name,dir)
    @dir = dir
    @guid = guid
    @name = name
    @markdown = File.read(File.join(dir,name+" "+guid+".md"))
    raw_title,raw_values,*raw_body = @markdown.split("\n\n")
    @title = raw_title[2..-1]
    @body = raw_body.join("\n\n")
    @values = {}
    raw_values.split("\n").each do |line|
      res = /(?<key>.*): (?<val>.*)/.match(line)
      key = res['key']
      val = res['val']
      values[key] = val
    end
    values['Guid'] = guid
    values['Name'] = name
    values['Kumu Link'] = "https://www.kumu.so/"+name+"-"+guid
  end
  attr_reader :dir, :guid, :name, :markdown, :title, :body, :values
end

class KumuDatabase
  def initialize(site,name,guid)
    @path = File.join(site.source,'..','data-processing','scopes','kumu')
    @guid = guid
    @name = name
    @csv = File.join(@path,name + ' '+guid+'.csv')
    @dir = File.join(@path,name + ' '+guid)
    @files = []
    self.scan_dir
  end
  attr_reader :path, :guid, :name, :csv, :dir, :files
  def scan_dir()
    Dir.each_child(@dir) do |filename|
      res = /(?<name>.*)\ (?<guid>[0-9a-fA-F]{32})\.md/.match(filename)
      guid = res['guid']
      name = res['name']
      @files << KumuMarkdownFile.new(guid,name,@dir)
    end
  end
end
