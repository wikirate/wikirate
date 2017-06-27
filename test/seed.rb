# -*- encoding : utf-8 -*-
require "timecop"
require_relative "shared_data/profile_sections"
require_relative "shared_data/metrics"
require_relative "shared_data/badges"
require_relative "shared_data/notes_and_sources"
require_relative "shared_data/samples"

require_dependency "card"

class SharedData
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
  }.freeze

  TOPICS = {
    "Force" => "A Jedi uses the Force for knowledge and defense, never for attack.",
    "Taming" => "What a cute animal"
  }.freeze

  class << self
    include Card::Model::SaveHelper
    include Samples

    include ProfileSections
    include Metrics
    include Badges
    include NotesAndSources

    def add_wikirate_data
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot
      add :companies, :topics, :analysis, :notes_and_sources,
          :metrics, :yearly_variables,
          :projects, :industry,
          :profile_sections, :badges

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
      # create "Delaware (United States)", type_id: Card::JurisdictionID,
      #                                    codename: "us_de"
      # create "California (United States)", type_id: Card::JurisdictionID,
      #                                      codename: "us_ca"
      ensure_card ["Google Inc", :headquarters],
                  type: :pointer, content: "California (United States)"
      ensure_card ["Google Inc", :incorporation],
                  type: :pointer, content: "Delaware (United States)"
      ensure_card ["Google Inc", :open_corporates], content: "3582691"
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
                                     content: "1006.5" } }
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
  end
end
