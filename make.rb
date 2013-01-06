#!/usr/bin/env ruby

require 'rest_client'
require "stringio"

#
# Handle arguments
#

$options = {
  :make_class   => ARGV.delete("class")     != nil,
  :make_mobile  => ARGV.delete("mobile")    != nil,
  :fresh        => ARGV.delete("--fresh")   != nil,
  :verbose      => ARGV.delete("--verbose") != nil,
  :help         => ARGV.delete("--help")    != nil
}

if ARGV.length > 0 or $options[:help] or (!$options[:make_class] and !$options[:make_mobile])
  
  commands = {
    "class"     => "Makes a Tangerine Class APK",
    "mobile"    => "Makes a regular Tangerine APK",
    "--fresh"   => "Starts with a new database",
    "--verbose" => "Outputs additional information",
    "--help"    => "..."
  }
  plural = if ARGV.length > 1 then "s" else "" end
  puts "\nTangerine make script\n\nUsage: make [class|mobile] --fresh --verbose --help\n"
  if $options[:help] then
    puts "\n"
    commands.each_pair do |opt, desc| printf "    %-20s %s\n", opt, desc end
  end
  puts "Unrecognized argument#{plural}: #{ARGV.join(',')}" if ARGV.length > 0
  puts "\n"
  exit(2)
end


#
# Helper functions
#

# handles verbosity
def check_step(response="", intent="")

  if response.downcase.include? "error"
    puts "Aborting. Error while attempting to #{intent}."
    puts split("\n").select { |line| line if line.downcase.include? "error" }
    exit(2)
  end
  
  if response.downcase.include? "warning"
    puts response.split("\n").select { |line| line if line.downcase.include? "warning" }
  elsif $options[:verbose]
    puts response 
  end
  
end


# Shows user nice updates
def section(title="")
  puts "\n\n*** #{title}\n"
  yield
  puts "Done."
end


# capture standard error
def bite_tongue
  previous_stderr, $stderr = $stderr, StringIO.new
  yield
  $stderr.string
ensure
  $stderr = previous_stderr
end


#
# Config
#

time = Time.new

home_dir        = ENV['HOME']
backup_dir      = "#{home_dir}/tangerine-apks/"
relative_to_app = "../app/"

version    = `git log --pretty=format:'%h' -n 1`
date_hour  = "#{time.year}-#{time.month}-#{time.day}-#{time.day}"

if $options[:make_class]
  package_name = "org.rti.tangerineclass"
  app_name     = "Tangerine Class"
  context      = "class"
elsif $options[:make_mobile]
  package_name = "org.rti.tangerine"
  app_name     = "Tangerine"
  context      = "mobile"
end


#
# Prepare CouchDB
#
section "Preparing couch" do

  # reverted to "server" after push
  File.open("#{relative_to_app}_docs/configuration.json", "r+") { |file|
    newText = file.read.sub(/\"context(.*)\"/, "\"context\" : \"#{context}\"")
    file.seek(0)
    file.truncate(0)
    file.write newText
  }

  if $options[:new_database]

    begin
      check_step RestClient.delete("http://tangerine:tangytangerine@localhost:5984/tangerine"), "delete database"
    rescue
      nil
    end
    check_step RestClient.put("http://tangerine:tangytangerine@localhost:5984/tangerine", "", :content_type => 'application/json'), "create new database"

  end

  bite_tongue do
    check_step `cd #{relative_to_app}; couchapp push; cd -`, "push with Couchapp"
  end

  File.open("#{relative_to_app}_docs/configuration.json", "r+") { |file|
    newText = file.read.sub(/\"context(.*)\"/, "\"context\" : \"server\"")
    file.seek(0)
    file.truncate(0)
    file.write newText
  }

  check_step RestClient.post("http://tangerine:tangytangerine@localhost:5984/tangerine/_compact", "", :content_type => 'application/json'), "compact database"

end


#
# Prepare the source
#

section "Preparing source" do

  File.open("AndroidManifest.xml", "r+") { |file|
    newText = file.read.sub(/package=\"(.*?)\"/, "package=\"#{package_name}\"")
    file.seek(0)
    file.truncate(0)
    file.write newText
  }

  File.open("res/values/strings.xml", "r+") { |file|
    newText = file.read.sub(/\<string name=\"app_name\"\>(.*?)\<\/string\>/, "<string name=\"app_name\">#{app_name}</string>")
    file.seek(0)
    file.truncate(0)
    file.write newText
  }

  File.open("src/Tangerine.java", "r+") { |file|
    newText = file.read.sub(/package(.*?);/, "package #{package_name};")
    file.seek(0)
    file.truncate(0)
    file.write newText
  }

end


#
# Get on with the building
#

bite_tongue do

  section "Building" do
    check_step `ant clean`, "clean with ant"
    check_step `ant debug`, "build APK"
  end

  section "Installing" do
    check_step `adb uninstall org.rti.tangerineclass`, "uninstall old APK"
    check_step `adb install bin/Tangerine-debug.apk`, "install new APK"
  end

  # Save backup
  check_step `cp bin/Tangerine-debug.apk #{backup_dir}Tangerine-#{date_hour}-#{version}.apk`, "make backup"

end

puts "\nAll done. Enjoy your #{if $options[:fresh] then "fresh " else "" end}Tangerine.\n\n"

