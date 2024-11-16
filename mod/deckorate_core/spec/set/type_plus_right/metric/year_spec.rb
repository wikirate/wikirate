# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::Year do
  # only has records for Samsung in 2014, 2015
  let(:metric) { Card["Joe User+researched number 3"] }

  # event in in Abstract::Applicability
  describe "event: verify_no_current_records_inapplicable" do
    it "disallows restriction that invalidates current researched records" do
      expect { metric.year_card.update! content: ["2014"] }
        .to raise_error /would disallow existing/
    end

    it "does not disallow valid restrictions" do
      expect { metric.year_card.update! content: %w[2014 2015] }
        .not_to raise_error
    end
  end
end
