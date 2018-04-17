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
      Card::Metric.create name: "Jedi+more evil",
                          type: :relationship,
                          random_source: true,
                          value_type: "Category",
                          value_options: %w(yes no),
                          inverse_title: "less evil" do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "yes" }
        Death_Star "1977" => { "Los_Pollos_Hermanos" => "yes", "SPECTRE" => "yes" }
      end

      Card::Metric.create name: "Commons+Supplied by",
                          type: :relationship,
                          random_source: true,
                          value_type: "Category",
                          value_options: ["Tier 1 Supplier", "Tier 2 Supplier"],
                          inverse_title: "Supplier of" do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" },
                "2000" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier",
                            "Google Inc." => "Tier 2 Supplier" }
        Monster_Inc "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" }
      end

      Card::Metric.create name: "Clean Clothes Campaign+Address",
                          type: :researched,
                          value_type: "Free Text",
                          random_source: true do
        SPECTRE "1977" => "Baker Street, London"
        Monster_Inc "1977" => "Alderaan"
        Google_Inc 2000 => "Mountain View"
      end
    end
  end
end
