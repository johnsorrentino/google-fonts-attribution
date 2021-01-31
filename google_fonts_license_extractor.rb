require 'nokogiri'
require 'open-uri'
require 'json'

# Scrapes the license and copyright information from Google Fonts attribution page.
class GoogleFontsLicenseExtractor
  def initialize
    @fonts = {
      kind: 'webfonts#webfontList',
      items: []
    }
  end

  def execute
    page.css('table > tr').each do |row|
      if row.classes.include?('header')
        create_font(row)
      else
        create_variant(row)
      end
    end
    save_as_json
  end

  private

  def page
    url = 'https://fonts.google.com/attribution'
    html = URI.parse(url).open
    Nokogiri::HTML(html)
  end

  def create_font(row)
    family = row.css('td.family').text
    license = row.css('td.license').text
    @fonts[:items] << {
      family: family,
      license: license,
      copyright: nil
    }
  end

  def create_variant(row)
    cell = row.css('td.copyright').text
    copyright = cell.split(': ').last
    @fonts[:items].last[:copyright] = copyright
  end

  def save_as_json
    file = File.open('./google-fonts-license-list.json', 'w+')
    file.write(JSON.pretty_generate(@fonts))
    file.close
  end
end

GoogleFontsLicenseExtractor.new.execute
