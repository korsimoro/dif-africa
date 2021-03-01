module Jekyll
  module NotionDateFilters
    require 'date'
    def notion_date_select_upcoming(collection,field)
      collection.reject { |x|  Date.parse(x[field], '%M, %$d %Y') < Date.today }
    end
    def notion_date_select_history(collection,field)
      collection.reject { |x|  Date.parse(x[field], '%M, %$d %Y') > Date.today }
    end
    def notion_date_select_next(collection,field)
      upcoming = self.notion_date_select_upcoming(collection,field)
      sorted = self.notion_date_sort(upcoming,field)
      puts sorted[0].inspect
      sorted[0]
    end

    def notion_date_sort(collection,field)
      collection.sort_by do |el|
        Date.parse(el[field], '%M, %$d %Y')
      end
    end

    def notion_date_days_until(item,field)
      (Date.parse(item[field], '%M, %$d %Y') - Date.today).to_i
    end

  end
end
Liquid::Template.register_filter(Jekyll::NotionDateFilters)
