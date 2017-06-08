RSpec.describe Card::Set::Type::Metric, 'json export' do
  let(:metric) { Card["Joe User+researched number 2"] }
  subject do
    render_view :core, { name: "Joe User+researched number 2"}, format: :json
  end

  specify "core view" do
    is_expected.to eq(
      metric:  { id: metric.id }
    )
  end
end
