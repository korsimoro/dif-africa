module Jekyll
  class CountryPageGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'country_index'
        dir = site.config['country_dir'] || 'country'
        site.data['country'].each do |country|
          name = Jekyll::Utils.slugify(country['name'])
          site.pages << CountryPage.new(site, site.source, File.join(dir, name), country)
        end
      end
    end
  end

  # A Page subclass used in the `CountryPageGenerator`
  class CountryPage < Page
    def initialize(site, base, dir, country)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'country_index.html')
      self.data['country'] = country

      country_title_prefix = site.config['country_title_prefix'] || 'Country: '
      self.data['title'] = "#{country_title_prefix}#{country['name']}"
    end
  end
end
