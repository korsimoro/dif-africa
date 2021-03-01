Gem::Specification.new do |s|
  s.name        = 'difasia'
  s.version     = '0.0.0'
  s.date        = '2010-04-28'
  s.summary     = "DIF Asia Repository Support"
  s.description = "Support for moving data from kumu, notion, github, and google"
  s.authors     = ["Eric Welton"]
  s.email       = 'eric@korsimoro.com'
  s.files       = [
	"lib/model/database.rb",
	"lib/model/schedule_entry.rb",
	"lib/model/country.rb",
	"lib/model/company.rb",
	"lib/data/database.rb",
	"lib/data/notion.rb",
	"lib/data/yaml.rb",
	"lib/commands/MyNewCommand.rb"
	]
  s.homepage    =
    'https://'
  s.license       = 'TBD'
end
