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
    Answer.where(metric_id: Card.fetch_id("Joe User+#{@metric_title}"),
                 company_id: Card.fetch_id(company), year: year.to_i).take
  end

  context "with two ancestors" do
    before do
      @metric_title = "descendant1"
      @metric = create_metric(
        name: @metric_title, type: :descendant,
        formula: "[[Joe User+researched number 2]]\n" \
                 "[[Joe User+researched number 1]]"
      )
    end

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
      let(:formula_format) { @metric.fetch(trait: :formula).format }

      it "renders pointer edit view" do
        expect(formula_format.render(:edit)).to have_tag("ul._pointer-filtered-list")
      end

      it "renders ancestors in formula core" do
        expect(formula_format.render(:core)).to have_tag("h6") { "Inherit from:" }
      end
    end
  end
end
