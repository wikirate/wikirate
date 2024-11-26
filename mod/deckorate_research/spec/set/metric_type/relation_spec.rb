RSpec.describe Card::Set::MetricType::Relation do
  def card_subject
    Card["Jedi+more evil"]
  end

  check_views_for_errors

  describe "create" do
    before do
      create "Joe User+bigger than",
             type_id: Card::MetricID,
             fields: {
               metric_type: "Relation",
               inverse_title: "smaller than"
             }
    end

    let(:metric) { Card["Joe User+bigger than"] }
    let(:inverse_metric) { Card["Joe User+smaller than"] }

    it "creates metric" do
      expect(metric).to be_instance_of Card
      expect(metric.type_name).to eq "Metric"
      expect(metric.relation?).to be true
      expect(metric.metric_type).to eq "Relation"
    end

    it "creates inverse metric" do
      expect(inverse_metric).to be_instance_of Card
      expect(inverse_metric.type_name).to eq "Metric"
      expect(inverse_metric.relation?).to be true
      expect(inverse_metric.metric_type).to eq "Inverse Relation"
    end

    it "links relation metric to inverse" do
      expect(metric.inverse_card).to eq inverse_metric
    end

    it "links inverse relation metric to relation metric" do
      expect(inverse_metric.inverse_card).to eq metric
    end

    it "links inverse titles" do
      expect(Card["bigger than+inverse"].item_names)
        .to contain_exactly "smaller than"

      expect(Card["smaller than+inverse"].item_names)
        .to contain_exactly "bigger than"
    end
  end

  describe "event: delete_relationships" do
    let(:metric) { "Jedi+more evil" }
    let(:metric_card) { Card[metric] }
    let(:company) { "SPECTRE" }

    def delete_answers
      Card::Env.with_params company: company do
        metric_card.update trigger: :delete_relationships
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

    it "does not delete unrelated object answer", as_bot: true do
      delete_answers
      unrelated_answer = Card["#{metric}+Death Star+1977+Los Pollos Hermanos"]
      expect(unrelated_answer).to be_instance_of(Card)
    end
  end

  specify "legend view" do
    expect_view(:legend, format: :base).to eq("related companies")
    expect_view(:legend, format: :html)
      .to have_tag("span.metric-legend", text: "related companies")
  end

  it "is researchable" do
    expect("Jedi+more evil".card).to be_researched
  end
end
