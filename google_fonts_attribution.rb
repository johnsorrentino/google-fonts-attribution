# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'json'

# Scrapes the license and copyright information from Google Fonts attribution page.
class GoogleFontsAttribution
  def execute
    fonts = { kind: 'webfonts#webfontList', items: [] }
    page.css('table > tr').each do |row|
      if row.classes.include?('header')
        fonts[:items] << item(row)
      else
        fonts[:items].last[:copyright] = copyright(row)
      end
    end
    fonts
  end

  private

  def page
    url = 'https://fonts.google.com/attribution'
    html = URI.parse(url).open
    Nokogiri::HTML(html)
  end

  def item(row)
    family = row.css('td.family').text
    license_name = row.css('td.license').text
    license_url = row.css('td.license > a').first['href']
    {
      family: family,
      license_name: license_name,
      license_url: license_url,
      copyright: nil
    }
  end

  def copyright(row)
    cell = row.css('td.copyright').text
    cell.split(': ').last
  end
end
