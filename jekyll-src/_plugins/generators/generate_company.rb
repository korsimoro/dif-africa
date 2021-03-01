module Jekyll
  class CompanyPageGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'company_index'
        dir = site.config['company_dir'] || 'company'
        site.data['company'].each do |company|
          name = Jekyll::Utils.slugify(company['name'])
          site.pages << CompanyPage.new(site, site.source, File.join(dir, name), company)
        end
      end
    end
  end

  # A Page subclass used in the `CompanyPageGenerator`
  class CompanyPage < Page
    def initialize(site, base, dir, company)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'company_index.html')
      self.data['company'] = company

      company_title_prefix = site.config['company_title_prefix'] || 'Company: '
      self.data['title'] = "#{company_title_prefix}#{company['name']}"
    end
  end
end
