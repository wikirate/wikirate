# -*- encoding : utf-8 -*-

require "timecop"

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
    "SPECTRE" => "shaken not stirred",
    "Google LLC" => "don't be evil" # ,
    # "Global Reporting Initiative" => "I'm just here for the industry hack."

    # in addition pulled from production:
    # Google Inc, Apple Inc, Samsung, Siemens AG, Sony Corporation, Amazon.com
  }.freeze

  TOPICS = {
    "Force" => "A Jedi uses the Force for knowledge and defense, never for attack.",
    "Taming" => "What a cute animal"
    # in addition pulled from production:
    # Natural Resource Use, Community, Human Rights, Climate Change, Animal Welfare
  }.freeze

  extend Samples
  extend ProfileSections
  extend ResearchedMetrics
  extend CalculatedMetrics
  extend RelationshipMetrics
  extend Badges
  extend Sources

  class << self
    include Card::Model::SaveHelper

    def add_wikirate_data
      puts "adding wikirate data".green
      setup
      add :companies, :topics, :sources, :report_types,
          :researched_metrics, :calculated_metrics, :relationship_metrics,
          :company_category, :researchers, :company_group,
          :profile_sections, :badges, :import_files, :guides

      Card::Cache.reset_all
      Answer.refresh
    end

    def setup
      Card::Cache.reset_all
      Card::Env.reset
      Card::Auth.signin "Decko Bot"
      Cardio.config.x.import_sources = false
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
      ensure_card ["Google LLC", :headquarters],
                  type: :pointer, content: "California (United States)"
      ensure_card ["Google LLC", :alias],
                  type: :pointer, content: %w[Google Alphabet]
      ensure_card ["Google LLC", :incorporation],
                  type: :pointer, content: "Delaware (United States)"
      ensure_card ["Google LLC", :open_corporates], content: "201727810678"
    end

    def add_topics
      TOPICS.each do |topic, about|
        create topic,
               type: "topic",
               subcards: { "+about" => about }
      end
    end

    def bookmark name
      Card::Auth.as_bot do
        Card::Auth.current.bookmarks_card.add_item! name
      end
    end

    def add_researchers
      researchers = Card.fetch "Jedi+Researchers", new: {}
      researchers.add_item! "Joe User"
      researchers.add_item! "Joe Camel"
    end

    def add_company_category
      metric = :commons_company_category.card
      metric.value_type_card.update! content: "Multi-Category"
      metric.value_options_card.update! content: %w[A B C D].to_pointer_content
      ["Death Star", "SPECTRE"].each do |name|
        metric.create_answer company: name,
                             year: "2019",
                             value: "A",
                             source: :opera_source.cardname
      end
    end

    def add_company_group
      create "Deadliest",
             type: :company_group,
             subfields: {
               specification: "[[Jedi+deadliness]],1977,\"{\"\"from\"\":30}\""
             }
      create "Googliest",
             type: :company_group,
             subfields: {
               specification: "explicit",
               wikirate_company: "Google LLC"
             }
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

    def add_guides
      create "Force Guide",
             type: :guide_type,
             subfields: {
               description: "guided by guy dead",
               body: "my body is a force"
             }
    end


    def csv_file name
      path = ::File.expand_path("../shared_data/file/#{name}.csv", __FILE__)
      ::File.open path
    end
  end
end
