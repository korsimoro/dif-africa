require_relative "../lib/notion_link.rb"
module Jekyll
  module NameFromNotionLink
    def name_from_notion_link(input)
      link = NotionLink.new_from_link(input)
      link.label
    end
  end
end

Liquid::Template.register_filter(Jekyll::NameFromNotionLink)
