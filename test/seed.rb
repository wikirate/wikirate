# -*- encoding : utf-8 -*-
require "timecop"
require_relative "shared_data/profile_sections"
require_relative "shared_data/metrics"

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

  class << self
    include Card::Model::SaveHelper
    include ProfileSections
    include Metrics

    def as_joe_user &block
      as_user "Joe User", &block
    end

    def account_args hash
      { "+*account" => { "+*password" => "joe_pass" }.merge(hash) }
    end

    def add_wikirate_data
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.as_bot
      add_companies
      add_topics_and_analysis
      add_sources_and_claims
      add_metrics
      vote_on_metrics
      add_yearly_variables
      add_projects
      add_industry
      add_profile_sections
      Answer.refresh
    end

    def add_companies
      COMPANIES.each do |company, about|
        create company,
               type: "company",
               subcards: { "+about" => about }
      end
    end

    def add_topics_and_analysis
      create "Force",
             type: "topic",
             subcards: {
               "+about" => "A Jedi uses the Force for " \
                           "knowledge and defense, never for attack."
             }

      create "Death Star+Force",
             type: "analysis",
             subcards: { "+article" => { content: "I'm your father!" } }


    end

    def add_sources_and_claims
      Timecop.freeze(Time.now + 1.day) do
        Card.create!(
          type_id: Card::SourceID,
          subcards: {
            "+Link" => { content: "http://www.wikiwand.com/en/Space_opera" },
            "+company" => { content: "[[Death Star]]", type_id: Card::PointerID },
            "+topic" => { content: "[[Force]]", type_id: Card::PointerID },
            "+title" => { content: "Space Opera" },
            "+description" => { content: "Space Opera Wikipedia article" }
          }
        )
      end

      Timecop.freeze(Time.now + 2.days) do
        Card.create!(
          type_id: Card::SourceID,
          subcards: {
            "+Link" => { content: "http://www.wikiwand.com/en/Opera" },
            "+title" => { content: "Opera" },
            "+description" => { content: "Opera Wikipedia article" }
          }
        )
      end

      sourcepage = Card.create!(
        type_id: Card::SourceID,
        subcards: {
          "+Link" => { content: "http://www.wikiwand.com/en/Star_Wars" },
          "+company" => { content: "[[Death Star]]", type_id: Card::PointerID },
          "+topic" => { content: "[[Force]]", type_id: Card::PointerID },
          "+title" => { content: "Star Wars" },
          "+description" => { content: "Star Wars Wikipedia article" }
        }
      )

      Card.create!(
        name: "Death Star uses dark side of the Force",
        type_id: Card::ClaimID,
        subcards: {
          "+source" => {
            content: "[[#{sourcepage.name}]]", type_id: Card::PointerID
          },
          "+company" => {
            content: "[[Death Star]]", type_id: Card::PointerID
          },
          "+topic" => {
            content: "[[Force]]", type_id: Card::PointerID
          }
        }
      )
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
                       "+value" => { type_id: Card::YearlyValueID, content:
                         "1007.5" }
          },
          "+2014" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID, content:
                         "1007" }
          },
          "+2013" => { type_id: Card::YearlyAnswerID,
                       "+value" => { type_id: Card::YearlyValueID, content:
                         "1006.5" }
          }
        }
      )
    end

    def add_projects
      create "Evil Project", type: :project,
             subfields: {
               metric:
                 { type: :pointer, content: "[[Jedi+disturbances in the Force]]\n[[Joe User+researched number 2]]" },
               wikirate_company:
                 { type: :pointer,
                   content: "[[Death Star]]\n[[SPECTRE]]\n[[Los Pollos Hermanos]]" }
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
