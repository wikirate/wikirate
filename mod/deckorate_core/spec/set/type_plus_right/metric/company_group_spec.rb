# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::CompanyGroup do
  # only has answers for Samsung in 2014, 2015
  let(:metric) { Card["Joe User+researched number 3"] }

  # event in in Abstract::Applicability
  describe "event: verify_no_current_answer_inapplicable" do
    it "disallows restriction that invalidates current researched answers" do
      expect { metric.company_group_card.update! content: "Googliest" }
        .to raise_error /would disallow existing/
    end

    it "does not disallow valid restrictions", as_bot: true do
      Card["Googliest"].company_card.update! content: "Samsung"
      expect { metric.company_group_card.update! content: "Googliest" }
        .not_to raise_error
    end

    context "with illegal item option" do
      it "does not run check (respects other error)" do
        expect { metric.company_group_card.update! content: "Death Star" }
          .to raise_error /invalid type/
      end
    end
  end
end
