RSpec.describe Card::Set::MetricType::Descendant do
  let(:metric_type) { :descendant }

  describe "descendant card" do
    let(:descendant_card) { Card[:descendant] }

    it { is_expected.to be_truthy }
    it "has codename" do
      expect(descendant_card.codename).to eq :descendant
    end
    it 'has type "metric type"' do
      expect(descendant_card.type_id).to eq Card::MetricTypeTypeID
    end
  end

  def inherited_value company, year
    inherited_answer(company, year)&.value
  end

  def inherited_answer company, year
    Answer.where(metric_id: metric_name.card_id,
                 company_id: company.card_id,
                 year: year.to_i).take
  end

  context "with two ancestors" do
    let(:metric_name) { "Joe User+descendant 1" }
    let(:metric) { Card[metric_name] }

    context "with answers" do
      it "uses first ancestor when both are present" do
        expect(inherited_value("Samsung", "2014")).to eq("5")
      end

      it "uses second ancestor when only second is present" do
        expect(inherited_value("Death_Star", "1977")).to eq("5")
      end

      it "has no answer when neither are present" do
        expect(inherited_value("Sony_Corporation", "1977")).to eq(nil)
      end
    end

    context "with views" do
      it "renders pointer edit view" do
        expect(metric.variables_card.format.render_edit)
          .to have_tag("ul._filtered-list")
      end

      it "renders ancestors in formula view" do
        expect(metric.format.render_formula)
          .to have_tag("div", class: "formula-algorithm", text: /Inherit from ancestor/)
      end
    end
  end

  it "can handle unknown value" do
    expect_view(:expanded_details, card: "Joe User+descendant 2+Apple Inc+2002")
      .to have_tag "span.metric-value", text: "Unknown"
  end
end
