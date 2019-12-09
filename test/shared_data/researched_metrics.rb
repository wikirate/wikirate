require_relative "samples"

class SharedData
  # test data for metrics
  module ResearchedMetrics
    include Samples

    def add_researched_metrics
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      create_or_update "1977", type_id: Card::YearID
      create_metrics
      bookmark_metrics
    end

    def create_metrics
      metric =
        Card::Metric.create name: "Jedi+disturbances in the Force",
                            value_type: "Category",
                            value_options: %w[yes no],
                            topic: "Force",
                            research_policy: "Community Assessed",
                            test_source: :star_wars_source do
          Death_Star "1977" => "yes", "2000" => "yes", "2001" => "yes"
          Monster_Inc "1977" => "no", "2000" => "yes"
          Slate_Rock_and_Gravel_Company "1977" => "no", "2005" => "no"
          SPECTRE "2000" => "no"
        end

      Card::Metric.create name: "Fred+dinosaurlabor",
                          value_type: "Category",
                          value_options: %w[yes no],
                          research_policy: "Designer Assessed",
                          topic: "Taming",
                          test_source: true do
        Slate_Rock_and_Gravel_Company "1977" => "yes", "2000" => "yes"
        Monster_Inc "1977" => "no", "2000" => "no"
        Death_Star "1977" => "no", "2000" => "yes"
      end

      Timecop.freeze(HAPPY_BIRTHDAY) do
        source = sample_source(:star_wars).name
        metric.create_answers do
          Death_Star "1990" => { value: "yes", source: source }
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 1.day) do
        metric.create_answers true do
          Death_Star "1991" => "yes"
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 2.weeks) do
        metric.create_answers true do
          Death_Star "1992" => "yes"
        end
        Card["Fred+dinosaurlabor"].create_answers true do
          Death_Star "2010" => "yes"
        end
      end

      number_metrics
      money_metrics
      free_text_metrics
      researched_metrics
      category_metrics
    end

    def free_text_metrics
      source = sample_source(:star_wars).name
      Card::Metric.create name: "Jedi+Sith Lord in Charge",
                          value_type: "Free Text",
                          unit: "Imperial military units",
                          report_type: "Conflict Mineral Report",
                          test_source: true do
        Death_Star "1977" => { value: "Darth Sidious",
                               source: source }
      end

      Card::Metric.create name: "Jedi+Weapons",
                          value_type: "Free Text"
    end

    def money_metrics
      Card::Metric.create name: "Jedi+cost of planets destroyed",
                          test_source: :star_wars_source,
                          value_type: "Money",
                          unit: "USD" do
        Death_Star "1977" => 200
      end
    end

    def number_metrics
      Card::Metric.create name: "Jedi+deadliness",
                          test_source: :star_wars_source,
                          value_type: "Number" do
        Death_Star "1977" => 100
        SPECTRE "1977" => 50
        Los_Pollos_Hermanos "1977" => 40
        Slate_Rock_and_Gravel_Company "1977" => 20,
                                      "2003" => 8,
                                      "2004" => 9,
                                      "2005" => 10
        Samsung "1977" => "Unknown"
      end

      Card::Metric.create name: "Jedi+Victims by Employees",
                          test_source: true,
                          value_type: "Number" do
        SPECTRE "1977" => 5.30
        Death_Star "1977" => 0.31
        Los_Pollos_Hermanos "1977" => 0.002
        Monster_Inc "1977" => 0.001
        Slate_Rock_and_Gravel_Company "1977" => -0.01
        Samsung "1977" => "Unknown"
      end
    end

    def researched_metrics
      Card::Metric.create name: "Joe User+researched number 1",
                          type: :researched,
                          test_source: true do
        Samsung "2014" => 10, "2015" => 5
        Sony_Corporation "2014" => 1
        Death_Star "1977" => 5
        Apple_Inc "2015" => 100, "2002" => 100
      end
      Card::Metric.create name: "Joe User+researched number 2",
                          type: :researched,
                          test_source: true do
        Samsung "2014" => 5, "2015" => 2
        Sony_Corporation "2014" => 2
      end
      Card::Metric.create name: "Joe User+researched number 3",
                          type: :researched,
                          research_policy: "Designer Assessed",
                          topic: "Taming",
                          test_source: true do
        Samsung "2014" => 1, "2015" => 1
      end

      Card::Metric.create name: "Joe User+RM",
                          type: :researched,
                          test_source: true do
        Apple_Inc "2000" => 0, "2001" => "Unknown", "2002" => "Unknown",
                  "2010" => 10, "2011" => 11, "2012" => 12,
                  "2013" => 13, "2014" => 14, "2015" => 15
        Death_Star "1977" => 77
      end
    end

    def category_metrics
      Card::Metric.create name: "Joe User+small multi",
                          type: :researched,
                          value_type: "Multi-Category",
                          value_options: %w[1 2 3],
                          test_source: true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end

      Card::Metric.create name: "Joe User+big multi",
                          type: :researched,
                          value_type: "Multi-Category",
                          value_options: %w[1 2 3 4 5 6 7 8 9 10 11],
                          test_source: true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end

      Card::Metric.create name: "Joe User+small single",
                          type: :researched,
                          value_type: "Category",
                          value_options: %w[1 2 3],
                          test_source: true do
        Sony_Corporation "2010" => 1
      end

      with_joe_user do
        Card::Metric.create name: "Joe User+big single",
                            type: :researched,
                            value_type: "Category",
                            value_options: %w[1 2 3 4 5 6 7 8 9 10 11],
                            test_source: true do
          Sony_Corporation "2010" => 1,
                           "2009" => 9,
                           "2008" => 8,
                           "2007" => 7,
                           "2006" => 6,
                           "2005" => 5,
                           "2004" => 4,
                           "2003" => 3
        end
      end
    end

    def bookmark_metrics
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
