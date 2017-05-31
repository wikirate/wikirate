RSpec.describe Card::Set::Type::Metric, 'json export' do

  ANSWER_NAME = "Jedi+Sith Lord in Charge+Death_Star+1977"
  let(:answer) { Card[ANSWER_NAME] }
  subject do
    render_view :core, { name: ANSWER_NAME}, format: :json
  end

  it "core view" do
    is_expected.to eq(
      metric:  { id: metric.id }
    )
  end
end
