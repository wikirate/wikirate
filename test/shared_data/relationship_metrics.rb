require_relative "samples"

class SharedData
  # test data for relationship metrics
  module RelationshipMetrics
    include Samples

    def add_relationship_metrics
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      relationship_metrics
    end

    def relationship_metrics
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

      Card[:company_address].create_answers(true) do
        SPECTRE "1977" => "Baker Street, London"
        Monster_Inc "1977" => "Alderaan"
        Google_LLC 2000 => "Mountain View"
      end

      Card[:commons_has_brands].create_answers(true) do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "1" }
      end
    end
  end
end