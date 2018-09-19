RSpec.describe Card::Set::Type::Metric, "json export" do
  let(:metric) { Card["Joe User+researched number 2"] }

  describe "atom view" do
    subject { render_view :atom, { name: metric.name }, format: :json }

    specify do
      is_expected.to include(name: "Joe User+researched number 2",
                             id: metric.id,
                             url: "http://wikirate.org/Joe_User+researched_number_2.json",
                             type: "Metric",
                             designer: "Joe User",
                             title: "researched number 2",
                             project: ["Evil Project"],
                             question: nil,
                             value_type: ["Number"])
    end
  end

  describe "molecule view" do
    subject { render_view :molecule, { name: metric.name }, format: :json }

    specify do
      is_expected
        .to include(
          name: "Joe User+researched number 2",
          id: metric.id,
          url: "http://wikirate.org/Joe_User+researched_number_2.json",
          type: a_hash_including(name: "Metric"),
          records_url: "http://wikirate.org/Joe_User+researched_number_2+Record.json",
          ancestors: [
            a_hash_including(name: "Joe User"),
            a_hash_including(name: "researched number 2")
          ]
        )
    end
  end
end
