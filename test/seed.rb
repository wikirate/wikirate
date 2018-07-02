# -*- encoding : utf-8 -*-
require "timecop"
require_dependency "shared_data/profile_sections"
require_dependency "shared_data/researched_metrics"
require_dependency "shared_data/calculated_metrics"
require_dependency "shared_data/relationship_metrics"
require_dependency "shared_data/badges"
require_dependency "shared_data/notes_and_sources"
require_dependency "shared_data/samples"

class SharedData
  require_dependency "card"
  require_dependency "card/model/save_helper"

  HAPPY_BIRTHDAY = Time.utc(2035, 2, 5, 12, 0, 0).freeze
  # gift to Ethan's 60th birthday:
  # on the date above 3 tests will fail
  # (if you reseed the test database)

  COMPANIES = {
    "Death Star" => "Kuuuhhh Shhhhhh Kuuuhhhh Shhhhh",
    "Monster Inc" => "We scare because we care.",
    "Slate Rock and Gravel Company" => "Yabba Dabba Doo!",
    "Los Pollos Hermanos" => "I'm the one who knocks",
    "SPECTRE" => "shaken not stirred"
    # in addition pulled from production:
    # Google Inc, Apple Inc, Samsung, Siemens AG, Sony Corporation, Amazon.com
  }.freeze

  TOPICS = {
    "Force" => "A Jedi uses the Force for knowledge and defense, never for attack.",
    "Taming" => "What a cute animal"
    # in addition pulled from production:
    # Natural Resource Use, Community, Human Rights, Climate Change, Animal Welfare
  }.freeze

  class << self
    include Card::Model::SaveHelper
    include Samples

    include ProfileSections
    include ResearchedMetrics
    include CalculatedMetrics
    include RelationshipMetrics
    include Badges
    include NotesAndSources

    def add_wikirate_data
      puts "add wikirate data"
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot
      Cardio.config.x.import_sources = false
      add :companies, :topics, :analysis, :notes_and_sources,
          :yearly_variables,
          :researched_metrics, :calculated_metrics, :relationship_metrics,
          :projects, :industry,
          :profile_sections, :badges, :import_files

      Card::Cache.reset_all
      Answer.refresh
    end

    def add *categories
      categories.each do |cat|
        send "add_#{cat}"
      end
    end

    def with_joe_user &block
      with_user "Joe User", &block
    end

    def account_args hash
      { "+*account" => { "+*password" => "joe_pass" }.merge(hash) }
    end

    def add_companies
      COMPANIES.each do |company, about|
        create company,
               type: "company",
               subcards: { "+about" => about }
      end
      ensure_card ["Google Inc.", :headquarters],
                  type: :pointer, content: "California (United States)"
      ensure_card ["Google Inc.", :aliases],
                  type: :pointer, content: ["Google", "Alphabet"]
      ensure_card ["Google Inc.", :incorporation],
                  type: :pointer, content: "Delaware (United States)"
      ensure_card ["Google Inc.", :open_corporates], content: "3582691"
    end

    def add_topics
      TOPICS.each do |topic, about|
        create topic,
               type: "topic",
               subcards: { "+about" => about }
      end
    end

    def add_analysis
      create "Death Star+Force",
             type: "analysis",
             subfields: { overview: {
               content: "I am your father! {{Death Star uses dark side of the Force|cite}}"
             } }
    end

    def vote name, direction
      Card::Auth.as_bot do
        vcc = Card[name].vote_count_card
        vcc.send "vote_#{direction}"
        vcc.save!
      end
    end

    def add_yearly_variables
      Card.create!(
        name: "half year", type_id: Card::YearlyVariableID,
        subcards: {
          "+2015" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID,
                                     content: "1007.5" } },
          "+2014" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID,
                                     content: "1007" } },
          "+2013" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID,
                                     content: "1006.5" } },
          "+2004" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID,
                                     content: "1002" } }
        }
      )
    end

    def add_projects
      create "Evil Project",
             type: :project,
             subfields: {
               metric: {
                 type: :pointer,
                 content: "[[Jedi+disturbances in the Force]]\n"\
                          "[[Joe User+researched number 2]]"
               },
               wikirate_company: {
                 type: :pointer,
                 content: ["Death Star", "SPECTRE", "Los Pollos Hermanos"]
               },
               wikirate_topic: {
                 type: :pointer,
                 content: "Force"
               }
             }

      create "Empty Project",
             type: :project,
             subfields: {
               metric: {
                 type: :pointer,
                 content: ""
               },
               wikirate_company: {
                 type: :pointer,
                 content: ""
               }
             }
    end

    def add_industry
      ["Death Star", "SPECTRE"].each do |name|
        create "Global_Reporting_Initiative+Sector_Industry+#{name}+2015+value",
               type: :phrase,
               content: "Technology Hardware"
      end
    end

    def add_import_files
      create "answer import test", type: :answer_import_file, empty_ok: true
      create "feature answer import test",
             type: :answer_import_file,
             codename: "answer_import_test_with_file",
             answer_import_file: csv_file("answer_import"),
             storage_type: :coded,
             mod: :test
      create "feature relationship import test",
             type: :relationship_answer_import_file,
             codename: "relationship_import_test_with_file",
             relationship_answer_import_file: csv_file("relationship_import"),
             storage_type: :coded,
             mod: :test

      create "source import test", type: :source_import_file, empty_ok: true
      create "relationship answer import test",
             type: :relationship_answer_import_file, empty_ok: true
      create "answer from source import test",
             type: :source, subfields: { wikirate_link: "http://google.com/source" }
      create "answer from source import test+file", type: :file, empty_ok: true
    end

    def csv_file name
      path = File.expand_path("../shared_data/file/#{name}.csv", __FILE__)
      File.open path
    end

  end
end
