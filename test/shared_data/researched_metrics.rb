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
      update_problematic_metrics
      bookmark_metrics
    end

    def create_metrics
      metric = Card["Jedi+disturbances in the Force"]
      Card::Metric::AnswerCreator.new "Jedi+disturbances in the Force", :star_wars_source do
        Death_Star "1977" => "yes", "2000" => "yes", "2001" => "yes"
        Monster_Inc "1977" => "no", "2000" => "yes"
        Slate_Rock_and_Gravel_Company "1977" => "no", "2005" => "no"
        SPECTRE "2000" => "no"
      end.add_answers

      Card::Metric::AnswerCreator.new "Fred+dinosaurlabor", true do
        Slate_Rock_and_Gravel_Company "1977" => "yes", "2000" => "yes"
        Monster_Inc "1977" => "no", "2000" => "no"
        Death_Star "1977" => "no", "2000" => "yes"
      end.add_answers

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
      Card::Metric::AnswerCreator.new "Jedi+Sith Lord in Charge", true do
        Death_Star "1977" => { value: "Darth Sidious",
                               source: source }
      end.add_answers
    end

    def money_metrics
      Card::Metric::AnswerCreator.new "Jedi+cost of planets destroyed", :star_wars_source do
        Death_Star "1977" => 200
      end.add_answers
    end

    def number_metrics
      Card::Metric::AnswerCreator.new "Jedi+deadliness", :star_wars_source do
        Death_Star "1977" => 100
        SPECTRE "1977" => 50
        Los_Pollos_Hermanos "1977" => 40
        Slate_Rock_and_Gravel_Company "1977" => 20,
                                      "2003" => 8,
                                      "2004" => 9,
                                      "2005" => 10
        Samsung "1977" => "Unknown"
      end.add_answers

      Card::Metric::AnswerCreator.new "Jedi+Victims by Employees", true do
        SPECTRE "1977" => 5.30
        Death_Star "1977" => 0.31
        Los_Pollos_Hermanos "1977" => 0.002
        Monster_Inc "1977" => 0.001
        Slate_Rock_and_Gravel_Company "1977" => -0.01
        Samsung "1977" => "Unknown"
      end.add_answers
    end

    def researched_metrics
      Card::Metric::AnswerCreator.new "Joe User+researched number 1", true do
        Samsung "2014" => 10, "2015" => 5
        Sony_Corporation "2014" => 1
        Death_Star "1977" => 5
        Apple_Inc "2015" => 100, "2002" => 100
      end.add_answers

      Card::Metric::AnswerCreator.new "Joe User+researched number 2", true do
        Samsung "2014" => 5, "2015" => 2
        Sony_Corporation "2014" => 2
      end.add_answers

      Card::Metric::AnswerCreator.new "Joe User+researched number 3", true do
        Samsung "2014" => 1, "2015" => 1
      end.add_answers

      Card::Metric::AnswerCreator.new "Joe User+RM", true do
        Apple_Inc "2000" => 0, "2001" => "Unknown", "2002" => "Unknown",
                  "2010" => 10, "2011" => 11, "2012" => 12,
                  "2013" => 13, "2014" => 14, "2015" => 15
        Death_Star "1977" => 77
      end.add_answers
    end

    def category_metrics
      Card::Metric::AnswerCreator.new "Joe User+small multi", true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end.add_answers

      Card::Metric::AnswerCreator.new "Joe User+big multi", true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end.add_answers

      Card::Metric::AnswerCreator.new "Joe User+small single", true do
        Sony_Corporation "2010" => 1
      end.add_answers

      with_joe_user do
        Card::Metric::AnswerCreator.new "Joe User+big single", true do
          Sony_Corporation "2010" => 1,
                           "2009" => 9,
                           "2008" => 8,
                           "2007" => 7,
                           "2006" => 6,
                           "2005" => 5,
                           "2004" => 4,
                           "2003" => 3
        end.add_answers
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

    # this is in seed data with no metric type
    def update_problematic_metrics
      Card["Global Reporting Initiative+Sector Industry"].metric_type_card.save!
    end
  end
end
