RSpec.describe Card::Set::Type::MetricAnswer, "json export" do
  YEAR = "1977".freeze
  COMPANY_NAME = "Death_Star".freeze

  let(:answer) { Card.fetch(metric.name, COMPANY_NAME, YEAR) }
  let(:company) { Card[COMPANY_NAME] }

  def json_view view
    render_view view, { name: answer.name }, format: :json
  end

  def wr_url name
    "http://wikirate.org/#{name.to_name.url_key}.json"
  end

  describe "exported json researched metric answer" do
    let(:metric) { Card["Jedi+Sith_Lord_in_Charge"] }
    let(:source) { sample_source(:star_wars) }

    let(:metric_fields) do
      {
        id: metric.id,
        name: metric.name,
        url: wr_url(metric.name)
      }
    end
    let(:source_fields) do
      {
        id: source.id,
        name: source.name,
        url: wr_url(source.name),
        file_url: source.file_url #"http://www.wikiwand.com/en/Star_Wars.json"
      }
    end
    let(:company_fields) do
      {
        id: company.id,
        name: company.name,
        url: wr_url(COMPANY_NAME)
      }
    end
    let(:atom_fields) do
      {
        id: answer.id,
        name: answer.name,
        type: "Answer",
        url: wr_url(answer.name),
        metric: metric.name,
        company: COMPANY_NAME,
        year: YEAR,
        value: "Darth Sidious",
        record_url: wr_url("#{metric.name}+#{COMPANY_NAME}")
      }
    end
    let :molecule_fields do
      atom_fields.merge(
        type: a_hash_including(name: "Answer"),
        ancestors: a_collection_including(
          a_hash_including(company_fields),
          a_hash_including(metric_fields)
        ),
        sources: [a_hash_including(source_fields)]
      )
    end

    specify "atom view" do
      expect(json_view(:atom)).to include atom_fields
    end

    # TODO: break this into smaller specs
    # perhaps use a before(:all) block to render the json once and
    # then run separate tests for the different values.
    # Will be MUCH easier to debug.
    specify "molecule view" do
      expect(json_view(:molecule)).to include(molecule_fields)
    end

  end

  describe "exported json relationship metric answer" do
    let(:metric) { Card["Jedi+more evil"] }

    xspecify "atom view" do
      expect(json_view(:atom)).to include(
        relationships: a_collection_including(
          a_hash_including(company: a_hash_including(name: "SPECTRE"))
        )
      )
    end
  end

  describe "exported calculated answer" do
    let(:metric) { Card["Jedi+deadliness+Joe Camel"] }

    it "atom view has calculated value" do
      expect(json_view(:atom)[:value]).to eq("5.0")
    end
  end
end
