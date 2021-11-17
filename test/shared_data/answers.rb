class SharedData
  module Answers
    def add_answers
      create_or_update "1977", type_id: Card::YearID
      
      add :researched_answers, :calculated_answers, :relationship_answers,
          :company_category
    end

    def add_company_category
      metric = :commons_company_category.card
      ["Death Star", "SPECTRE"].each do |name|
        metric.create_answer company: name,
                             year: "2019",
                             value: "A",
                             source: :opera_source.cardname
      end
    end

    def add_researched_answers
      "Jedi+disturbances in the Force".card.create_answers :star_wars_source do
        Death_Star "1977" => "yes", "2000" => "yes", "2001" => "yes"
        Monster_Inc "1977" => "no", "2000" => "yes"
        Slate_Rock_and_Gravel_Company "1977" => "no", "2005" => "no"
        SPECTRE "2000" => "no"
      end

      "Fred+dinosaurlabor".card.create_answers true do
        Slate_Rock_and_Gravel_Company "1977" => "yes", "2000" => "yes"
        Monster_Inc "1977" => "no", "2000" => "no"
        Death_Star "1977" => "no", "2000" => "yes"
      end

      Timecop.freeze(HAPPY_BIRTHDAY) do
        "Jedi+disturbances in the Force".card.create_answers :star_wars_source do
          Death_Star "1990" => "yes"
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 1.day) do
        "Jedi+disturbances in the Force".card.create_answers true do
          Death_Star "1991" => "yes"
        end
      end
      Timecop.freeze(HAPPY_BIRTHDAY - 2.weeks) do
        "Jedi+disturbances in the Force".card.create_answers true do
          Death_Star "1992" => "yes"
        end
        "Fred+dinosaurlabor".card.create_answers true do
          Death_Star "2010" => "yes"
        end
      end
      
      "Jedi+Sith Lord in Charge".card.create_answers :star_wars_source do
        Death_Star "1977" => "Darth Sidious"
      end

      "Jedi+cost of planets destroyed".card.create_answers :star_wars_source do
        Death_Star "1977" => 200
      end

      "Jedi+deadliness".card.create_answers :star_wars_source do
        Death_Star "1977" => 100
        SPECTRE "1977" => 50
        Los_Pollos_Hermanos "1977" => 40
        Slate_Rock_and_Gravel_Company "1977" => 20,
                                      "2003" => 8,
                                      "2004" => 9,
                                      "2005" => 10
        Samsung "1977" => "Unknown"
      end

      "Jedi+Victims by Employees".card.create_answers true do
        SPECTRE "1977" => 5.30
        Death_Star "1977" => 0.31
        Los_Pollos_Hermanos "1977" => 0.002
        Monster_Inc "1977" => 0.001
        Slate_Rock_and_Gravel_Company "1977" => -0.01
        Samsung "1977" => "Unknown"
      end

      "Joe User+researched number 1".card.create_answers true do
        Samsung "2014" => 10, "2015" => 5
        Sony_Corporation "2014" => 1
        Death_Star "1977" => 5
        Apple_Inc "2015" => 100, "2002" => 100
      end

      "Joe User+researched number 2".card.create_answers true do
        Samsung "2014" => 5, "2015" => 2
        Sony_Corporation "2014" => 2
      end

      "Joe User+researched number 3".card.create_answers true do
        Samsung "2014" => 1, "2015" => 1
      end

      "Joe User+RM".card.create_answers true do
        Apple_Inc "2000" => 0, "2001" => "Unknown", "2002" => "Unknown",
                  "2010" => 10, "2011" => 11, "2012" => 12,
                  "2013" => 13, "2014" => 14, "2015" => 15
        Death_Star "1977" => 77
      end

      "Joe User+small multi".card.create_answers true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end

      "Joe User+big multi".card.create_answers true do
        Sony_Corporation "2010" => [1, 2].to_pointer_content
      end

      "Joe User+small single".card.create_answers true do
        Sony_Corporation "2010" => 1
      end

      with_joe_user do
        "Joe User+big single".card.create_answers true do
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

      Card[:company_address].create_answers(true) do
        SPECTRE "1977" => "Baker Street, London"
        Monster_Inc "1977" => "Alderaan"
        Google_LLC 2000 => "Mountain View"
      end
    end

    def add_calculated_answers
      "Jedi+friendliness".card.create_answers true do
        Slate_Rock_and_Gravel_Company 2003 => "100"
      end

      "Joe User+descendant hybrid".card.create_answers true do
        Death_Star 1977 => 1000
      end
    end

    def add_relationship_answers
      Card["Jedi+more evil"].create_answers true do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "yes" }
        Death_Star "1977" => { "Los_Pollos_Hermanos" => "yes", "SPECTRE" => "yes" }
      end

      Card["Commons+Supplied by"].create_answers(true) do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" },
                "2000" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier",
                            "Google LLC" => "Tier 2 Supplier" }
        Monster_Inc "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" }
      end

      Card[:commons_has_brands].create_answers(true) do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "1" }
      end
    end
  end
end
