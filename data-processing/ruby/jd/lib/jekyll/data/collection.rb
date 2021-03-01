
class CollectionMarkdownFile
  def initialize(filename,dir)
    @dir = dir
    @title = filename
    @markdown = File.read(File.join(dir,filename,".md"))
    raw_values,*raw_body = @markdown.split("^---")
    @body = raw_body.join("\n---")
    @values = {}
    raw_values.split("\n").each do |line|
      res = /(?<key>.*): (?<val>.*)/.match(line)
      key = res['key']
      val = res['val']
      values[key] = val
    end
  end
  attr_reader :dir, :guid, :name, :markdown, :title, :body, :values
end

class CollectionDatabase
  def initialize(site,name)
    super()
    basedir = File.join(site.source,'..','data-processing','scopes','repo')
    @name = name
    @dir = File.join(basedir,name)
    @files = []
    self.scan_dir
  end
  attr_reader :path, :guid, :name, :csv, :dir, :files
  def scan_dir()
    Dir.each_child(@dir) do |filename|
      @files << CollectionMarkdownFile.new(filename,@dir)
    end
  end
end
