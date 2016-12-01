# -*- encoding : utf-8 -*-
require "timecop"

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
      add_yearly_variables
      add_projects
      add_industry
      MetricAnswer.refresh
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
      sourcepage = Card.create!(
        type_id: Card::SourceID,
        subcards: {
          "+Link" => { content: "http://www.wikiwand.com/en/Star_Wars" },
          "+company" => { content: "[[Death Star]]", type_id: Card::PointerID },
          "+topic" => { content: "[[Force]]", type_id: Card::PointerID }
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

    def add_metrics
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      create_or_update "1977", type_id: Card::YearID
      metric =
        Card::Metric.create name: "Jedi+disturbances in the Force",
                            value_type: "Category",
                            value_options: %w(yes no),
                            random_source: true do
          Death_Star "1977" => "yes", "2000" => "yes", "2001" => "yes"
          Monster_Inc "1977" => "no", "2000" => "yes"
          Slate_Rock_and_Gravel_Company "1977" => "no", "2005" => "no"
          SPECTRE "2000" => "no"
        end

      Timecop.freeze(HAPPY_BIRTHDAY) do
        metric.create_values true do
          Death_Star "1990" => "yes"
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 1.day) do
        metric.create_values true do
          Death_Star "1991" => "yes"
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 2.weeks) do
        metric.create_values true do
          Death_Star "1992" => "yes"
        end
      end

      Card::Metric.create name: "Fred+dinosaurlabor",
                          value_type: "Category",
                          value_options: %w(yes no),
                          random_source: true do
        Slate_Rock_and_Gravel_Company "1977" => "yes", "2000" => "yes"
        Monster_Inc "1977" => "no", "2000" => "no"
        Death_Star "1977" => "no", "2000" => "yes"
      end

      Card::Metric.create name: "Jedi+deadliness",
                          random_source: true,
                          value_type: "Number" do
        Death_Star "1977" => 100
        SPECTRE "1977" => 50
        Los_Pollos_Hermanos "1977" => 40
        Slate_Rock_and_Gravel_Company "1977" => 20

      end

      Card::Metric.create name: "Jedi+cost of planets destroyed",
                          random_source: true,
                          value_type: "Money" do
        Death_Star "1977" => { value: 200 }
      end
      Card::Metric.create name: "Jedi+Sith Lord in Charge",
                          value_type: "Free Text"
      Card::Metric.create name: "Jedi+friendliness",
                          type: :formula,
                          formula: "1/{{Jedi+deadliness}}"
      Card::Metric.create name: "Jedi+deadliness+Joe User",
                          type: :score,
                          formula: "{{Jedi+deadliness}}/10"
      Card::Metric.create name: "Jedi+deadliness+Joe Camel",
                          type: :score,
                          formula: "{{Jedi+deadliness}}/20"
      Card::Metric.create name: "Jedi+disturbances in the Force+Joe User",
                          type: :score,
                          formula: { yes: 10, no: 0 }
      Card::Metric.create(
        name: "Jedi+darkness rating",
        type: :wiki_rating,
        formula: { "Jedi+deadliness+Joe User" => 60,
                   "Jedi+disturbances in the Force+Joe User" => 40 }
      )

      Card::Metric.create name: "Joe User+researched number 1",
                          type: :researched,
                          random_source: true do
        Samsung "2014" => 10, "2015" => 5
        Sony_Corporation "2014" => 1
        Death_Star "1977" => 5
        Apple_Inc "2015" => 100
      end
      Card::Metric.create name: "Joe User+researched number 2",
                          type: :researched,
                          random_source: true do
        Samsung "2014" => 5, "2015" => 2
        Sony_Corporation "2014" => 2
      end
      Card::Metric.create name: "Joe User+researched number 3",
                          type: :researched,
                          random_source: true do
        Samsung "2014" => 1, "2015" => 1
      end

      Card::Metric.create name: "Joe User+researched",
                          type: :researched,
                          random_source: true do
        Apple_Inc "2010" => 10, "2011" => 11, "2012" => 12,
                  "2013" => 13, "2014" => 14, "2015" => 15
        Death_Star "1977" => 77
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
                 { type: :pointer, content: "[[Jedi+disturbances in the Force]]" },
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
