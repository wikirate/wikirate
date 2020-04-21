RSpec.describe Card::Set::Type::Metric::Export do
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
          answers_url: "http://wikirate.org/Joe_User+researched_number_2+Answer.json",
          ancestors: [
            a_hash_including(name: "Joe User"),
            a_hash_including(name: "researched number 2")
          ]
        )
    end
  end

  describe "CsvFormat" do
    specify "view: csv_header" do
      expect_view(:csv_header, format: :csv)
        .to eq(["Questions", "*metric type", "Metric Designer", "Metric Title", "Topic",
                "About", "methodology", "value type", "value options", "Report Type",
                "Research Policy"])
    end

    specify "view: csv_line" do
      expect_view(:csv_line, format: :csv, card: metric)
        .to eq(["", "Researched", "Joe User", "researched number 2", "", "", "",
                "Number", "", "", "Community Assessed"])
    end
  end
end
