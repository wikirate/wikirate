#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

Wikirate::Application.load_tasks

Dir.glob("vendor/mods/lib/tasks/*.rake").each { |r| load r }
Dir.glob("vendor/wagn/lib/tasks/*.rake").each { |r| load r }
