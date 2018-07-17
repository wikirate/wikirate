RSpec.describe Card::Set::Type::MetricAnswer, "json export" do
  YEAR = "1977".freeze
  COMPANY_NAME = "Death_Star".freeze

  subject do
    render_view :core, { name: answer.name }, format: :json
  end

  let(:answer) { Card.fetch(metric.name, COMPANY_NAME, YEAR) }
  let(:company) { Card[COMPANY_NAME] }

  describe "exported json researched metric answer" do
    let(:metric) { Card["Jedi+Sith_Lord_in_Charge"] }
    let(:source) { sample_source("Star_Wars") }

    let(:metric_fields) do
      {
        id: metric.id,
        name: metric.name,
        key: metric.key,
        url: "http://wikirate.org/#{metric.name.url_key}",
        designer: "Jedi",
        title: "Sith Lord in Charge"
      }
    end
    let(:source_fields) do
      {
        id: source.id,
        name: source.name,
        key: source.key,
        source_url: "http://www.wikiwand.com/en/Star_Wars",
        title: instance_of(String)
      }
    end
    let(:company_fields) do
      {
        id: company.id,
        name: company.name,
        key: company.key,
        url: "http://wikirate.org/#{COMPANY_NAME}"
      }
    end
    let(:answer_fields) do
      {
        id: answer.id,
        name: answer.name,
        key: answer.key,
        url: "http://wikirate.org/#{answer.name.url_key}",
        comments: "",
        import: false,
        year: YEAR,
        value: "Darth Sidious",
        checked_by: [],
        metric: metric_fields,
        source: a_hash_including(source_fields),
        company: company_fields
      }
    end

    it "core view" do
      is_expected .to include answer_fields
    end
  end

  describe "exported json researched metric answer" do
    let(:metric) { Card["Jedi+more evil"] }

    it "core view" do
      is_expected .to include(
        relationships: a_collection_including(
          a_hash_including(company: a_hash_including(name: "SPECTRE"))
        )
      )
    end
  end
end
