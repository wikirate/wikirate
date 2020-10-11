require "decko/cap"
include Decko::Cap

Decko::Cap.each_cap_file { |file| import file }
Dir.glob("lib/capistrano/tasks/*.cap").each { |r| import r }
