require './google_fonts_attribution'

fonts = GoogleFontsAttribution.new.execute
file = File.open('./google-fonts-attribution.json', 'w+')
file.write(JSON.pretty_generate(fonts))
file.close
