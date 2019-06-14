changed_file = [ARGV][0][0].split('/')[1].split('.')

puts "#{changed_file.join('.')} was changed!"

# make extra sure the script is not processing files it was not intended for
if (changed_file[1] == "css" || changed_file[1] == "js") && changed_file.length == 2 && changed_file[0] != "site" && changed_file[0] != "phoenix_html"
  system("ruby asset_builder.rb #{changed_file[0]} #{changed_file[1]}")
end
