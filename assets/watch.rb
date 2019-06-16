changed_file = ARGV[0].split('/')[1].split('.')
action = ARGV[1]

if action == "unlink"
  return puts "'#{changed_file.join('.')}' was deleted. Make sure to clean up the /priv/static/css directory!"
end

puts "'#{changed_file.join('.')}' was changed!"

# make extra sure the script is not processing files it was not intended for
if ["css", "js", "scss"].include?(changed_file[1]) && changed_file.length == 2 && !["site", "phoenix_html"].include?(changed_file[0])
  system("ruby asset_builder.rb #{changed_file[0]} #{changed_file[1]}")
end
