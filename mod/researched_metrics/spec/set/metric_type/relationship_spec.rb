RSpec.describe Card::Set::MetricType::Relationship do
  def card_subject
    Card["Jedi+more evil+SPECTRE+1977+Los_Pollos_Hermanos"]
  end

  check_views_for_errors :edit

  describe "create" do
    before do
      create "Joe User+bigger than",
             type_id: Card::MetricID,
             subfields: {
               metric_type: "Relationship",
               inverse_title: "smaller than"
             }
    end

    let(:metric) { Card["Joe User+bigger than"] }
    let(:inverse_metric) { Card["Joe User+smaller than"] }

    it "creates metric" do
      expect(metric).to be_instance_of Card
      expect(metric.type_name).to eq "Metric"
      expect(metric.relationship?).to be true
      expect(metric.metric_type).to eq "Relationship"
    end

    it "creates inverse metric" do
      expect(inverse_metric).to be_instance_of Card
      expect(inverse_metric.type_name).to eq "Metric"
      expect(inverse_metric.relationship?).to be true
      expect(inverse_metric.metric_type).to eq "Inverse Relationship"
    end

    it "links relationship metric to inverse" do
      expect(metric.inverse_card).to eq inverse_metric
    end

    it "links inverse relationship metric to relationship metric" do
      expect(inverse_metric.inverse_card).to eq metric
    end

    it "links inverse titles" do
      expect(Card["bigger than+inverse"].item_names)
        .to contain_exactly "smaller than"

      expect(Card["smaller than+inverse"].item_names)
        .to contain_exactly "bigger than"
    end
  end

  describe "event: delete_relationship_answers" do
    let(:metric) { "Jedi+more evil" }
    let(:metric_card) { Card[metric] }
    let(:company) { "SPECTRE" }

    def delete_answers
      with_params company: company do
        metric_card.update trigger: :delete_relationship_answers
      end
    end

    it "fails without admin permission" do
      delete_answers
      expect(metric_card.errors).to have_key(:answers)
    end

    it "deletes subject answers", as_bot: true do
      delete_answers
      expect(Card.fetch(metric, company)).not_to be_real
    end

    it "deletes object answers", as_bot: true do
      delete_answers
      expect(Card["#{metric}+Death Star+1977+#{company}"]).to be_nil
    end

    it "does not delete unrelated object answers", as_bot: true do
      delete_answers
      unrelated_answer = Card["#{metric}+Death Star+1977+Los Pollos Hermanos"]
      expect(unrelated_answer).to be_instance_of(Card)
    end
  end

  it "is researchable" do
    expect(Card["Jedi+more evil"].researched?).to be_truthy
  end
end
