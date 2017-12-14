require_relative "samples"

class SharedData
  # test data for metrics
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
    end
  end
end
