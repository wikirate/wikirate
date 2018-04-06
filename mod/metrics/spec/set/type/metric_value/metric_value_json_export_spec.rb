RSpec.describe Card::Set::Type::MetricValue, "json export" do
  YEAR = "1977".freeze
  COMPANY_NAME = "Death_Star".freeze
  METRIC_NAME = "Jedi+Sith_Lord_in_Charge".freeze
  ANSWER_NAME = "#{METRIC_NAME}+#{COMPANY_NAME}+#{YEAR}".freeze

  subject do
    render_view :core, { name: ANSWER_NAME }, format: :json
  end

  let(:answer) { Card[ANSWER_NAME] }
  let(:company) { Card[COMPANY_NAME] }
  let(:metric) { Card[METRIC_NAME] }
  let(:source) { sample_source("Star_Wars") }

  let(:metric_fields) do
    {
      id: metric.id,
      name: metric.name,
      key: metric.key,
      url: "http://wikirate.org/#{METRIC_NAME}",
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
      url: "http://wikirate.org/#{ANSWER_NAME}",
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
