# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::Year do
  # only has answers for Samsung in 2014, 2015
  let(:metric) { Card["Joe User+researched number 3"]}

  describe "event: verify_no_current_answers_inapplicable" do
    it "disallows restriction that invalidates current researched answers" do
      expect { metric.company_group_card.update! content: "Googliest" }
        .to raise_error /would disallow existing/
    end

    it "does not disallow valid restrictions", as_bot: true do
      Card["Googliest"].wikirate_company_card.update! content: "Samsung"
      expect { metric.company_group_card.update! content: "Googliest" }
        .not_to raise_error
    end
  end
end
