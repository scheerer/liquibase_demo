require "erb"

def convert_erb_xml_file
  template_file = File.open("template.xml.erb", 'r').read
  erb = ERB.new(template_file)
  File.open("changesets/#{create_filename}", 'w+') { |file| file.write(erb.result(binding)) }
  puts "File successfully created: changesets/#{create_filename}"
end

def create_filename
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")
  description = ARGV[0]
  @filename = "#{timestamp}_#{description}.xml"
  if description
    @filename
  else
    raise "Requires a description in the format: this_is_a_description_string"
  end
end

def remove_temp_migrate_file
  begin
    try File.delete(".migrate.xml")
  rescue
  end
end

def rename_temp_migrate_file
  File.delete("migrate.xml")
  File.rename(".migrate.xml", "migrate.xml")
  rescue Exception => e
    puts e.errors
end

def add_entry_to_migrate_xml
  remove_temp_migrate_file

  migrate = File.readlines("migrate.xml")
  File.open('.migrate.xml', 'w') do |temp|

    # write each line until we hit the databaseChangeLog close tag
    migrate.each do |line|
      temp.puts line unless line =~ /<\/databaseChangeLog>/
    end

    # Once we hit the databseChangeLog close tag, add our newly created file
    # and then close the databaseChangeLog tag
    temp.puts "    <include file=\"changesets/#{@filename}\" relativeToChangelogFile=\"true\"/>"
    temp.puts '</databaseChangeLog>'
  end

  rename_temp_migrate_file
  puts "Entry added to migrate.xml"
end

convert_erb_xml_file
add_entry_to_migrate_xml
