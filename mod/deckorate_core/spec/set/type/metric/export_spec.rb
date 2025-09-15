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
                             value_type: "Number")
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
    # specify "view: header" do
    #   expect_view(:header, format: :csv)
    #     .to eq("Questions,Metric Type,Metric Designer,Metric Title,Scorer,Formula," \
    #            "Variables,Rubric,Topic,Unpublished,About,Methodology,Value Type,Unit," \
    #            "Range,Hybrid,Inverse Title,Value Options,Report Type,Assessment," \
    #            "Year,Company Group\n")
    # end

    specify "view: row" do
      expect_view(:row, format: :csv, card: metric)
        .to include("http://wikirate.org/~#{metric.id}", "Researched", "Joe User",
                    "researched number 2", "Number", "Community Assessed")
    end
  end
end
