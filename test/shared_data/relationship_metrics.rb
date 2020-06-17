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
                          test_source: true,
                          value_type: "Category",
                          value_options: %w[yes no],
                          inverse_title: "less evil" do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "yes" }
        Death_Star "1977" => { "Los_Pollos_Hermanos" => "yes", "SPECTRE" => "yes" }
      end

      # Card::Metric.create name: "Commons+Supplied by",
      #                     type: :relationship,
      #                     test_source: true,
      #                     value_type: "Category",
      #                     value_options: ["Tier 1 Supplier", "Tier 2 Supplier"],
      #                     inverse_title: "Supplier of" do
      Card.create name: "Commons+Supplied by+*metric type", content: "Relationship"
      Card.create name: "Commons+Supplied by+inverse", content: "Commons+Supplier of"
      Card.create name: "Commons+Supplier of+*metric type",
                  content: "Inverse Relationship"
      Card::Cache.reset_all
      Card["Commons+Supplied by"].create_answers(true) do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" },
                "2000" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier",
                            "Google LLC" => "Tier 2 Supplier" }
        Monster_Inc "1977" => { "Los_Pollos_Hermanos" => "Tier 1 Supplier" }
      end

      update_card "Commons+Supplier of", codename: "commons_supplier_of"

      # Card::Metric.create name: "Clean Clothes Campaign+Address",
      #                     type: :researched,
      #                     value_type: "Free Text",
      #                     test_source: true do
      #   SPECTRE "1977" => "Baker Street, London"
      #   Monster_Inc "1977" => "Alderaan"
      #   Google_Inc 2000 => "Mountain View"
      # end

      update_card "Clean Clothes Campaign+Address", codename: "company_address"
      # the Clean Clothes Campaign+Address metric
      Card[:company_address].create_answers(true) do
        SPECTRE "1977" => "Baker Street, London"
        Monster_Inc "1977" => "Alderaan"
        Google_LLC 2000 => "Mountain View"
      end

      Card::Metric.create name: "Commons+Has Brands",
                          type: :relationship,
                          test_source: true,
                          value_type: "Number",
                          inverse_title: "Is Brand Of" do
        SPECTRE "1977" => { "Los_Pollos_Hermanos" => "1" }
      end
    end
  end
end