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
      add :sources, :answers, :bookmarkings, :profile_sections, :import_files
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

    def bookmarkings
      with_user "Joe Admin" do
        bookmark "Jedi+disturbances in the Force"
        bookmark "Jedi+Victims by Employees"
      end
      with_user "Joe User" do
        bookmark "Jedi+disturbances in the Force"
      end
    end

    def add_import_files
      create "answer import test",
             type: :answer_import,
             codename: "answer_import_test_with_file",
             answer_import: csv_file("answer_import"),
             storage_type: :coded,
             mod: :test
      create "relationship import test",
             type: :relationship_import,
             codename: "relationship_import_test_with_file",
             relationship_import: csv_file("relationship_import"),
             storage_type: :coded,
             mod: :test
      create "source import test",
             type: :source_import,
             codename: "source_import_test_with_file",
             source_import: csv_file("source_import"),
             storage_type: :coded,
             mod: :test
    end

    def csv_file name
      path = ::File.expand_path("../shared_data/file/#{name}.csv", __FILE__)
      ::File.open path
    end
  end
end
