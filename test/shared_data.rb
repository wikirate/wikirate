# -*- encoding : utf-8 -*-

require "timecop"

class SharedData
  HAPPY_BIRTHDAY = Time.utc(2035, 2, 5, 12, 0, 0).freeze
  # gift to Ethan's 60th birthday:
  # on the date above 3 tests will fail
  # (if you reseed the test database)

  extend Answers
  extend ProfileSections

  class << self
    include Card::Model::SaveHelper

    def add_wikirate_data
      puts "adding wikirate data".green
      setup
      add :answers, :bookmarkings, :profile_sections
    end

    def setup
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.signin "Decko Bot"
      Cardio.config.x.import_sources = false
    end

    def add *categories
      categories.each do |cat|
        puts "adding #{cat}".green
        send "add_#{cat}"
      end
    end

    def with_joe_user &block
      with_user "Joe User", &block
    end

    def bookmark name
      Card::Auth.as_bot do
        Card::Auth.current.bookmarks_card.add_item! name
      end
    end

    def add_bookmarkings
      with_user "Joe Admin" do
        bookmark "Jedi+disturbances in the Force"
        bookmark "Jedi+Victims by Employees"
      end
      with_user "Joe User" do
        bookmark "Jedi+disturbances in the Force"
      end
    end
  end
end
