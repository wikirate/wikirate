RSpec.describe Card::Set::Type::Metric, 'json export' do

  YEAR = "1977"
  COMPANY_NAME = "Death_Star"
  METRIC_NAME = "Jedi+Sith_Lord_in_Charge"
  ANSWER_NAME = "#{METRIC_NAME}+#{COMPANY_NAME}+#{YEAR}"

  let(:answer) { Card[ANSWER_NAME] }
  let(:company) { Card[COMPANY_NAME]}
  let(:metric) { Card[METRIC_NAME]}
  let(:source) { sample_source("Star_Wars") }
  subject do
    render_view :core, { name: ANSWER_NAME}, format: :json
  end

  it "core view" do
    is_expected.to include(
      id: answer.id,
      name: answer.name,
      url: "/#{ANSWER_NAME}",
      comments: "",
      import: false,
      year: YEAR,
      value: "Darth Sidious",
      metric: {
        id: metric.id,
        name: metric.name,
        url: "/#{METRIC_NAME}",
        designer: "Jedi",
        title: "Sith Lord in Charge"
      },
      source: a_hash_including(
        id: source.id,
        name: source.name,
        source_url: "http://www.wikiwand.com/en/Star_Wars",
        title: instance_of(String)
      ),
      company: {
        id: company.id,
        name: company.name,
        url: "/#{COMPANY_NAME}"
      },
      checked_by: []
    )
  end
end
