RSpec.describe Card::Set::Type::Relationship::Views do
  let(:name) { "Commons+Supplied by+Monster_Inc+1977+Los_Pollos_Hermanos" }

  def card_subject
    Card[name]
  end

  def add_unit
    unit = card_subject.metric_card.unit_card
    unit.content = "buggers"
    unit.save!
  end

  describe "Format" do
    describe "view: legend" do
      context "without unit" do
        it "is blank" do
          expect_view(:legend, format: :base).to be_blank
        end
      end

      context "with unit" do
        it "shows unit" do
          add_unit
          expect_view(:legend, format: :base).to match(/buggers/)
        end
      end
    end
  end

  describe "HtmlFormat" do
    describe "view: legend" do
      context "without unit" do
        it "is blank" do
          expect_view(:legend).to be_blank
        end
      end

      context "with unit" do
        it "shows unit" do
          add_unit
          expect_view(:legend).to match(/buggers/)
        end
      end
    end
  end
end
