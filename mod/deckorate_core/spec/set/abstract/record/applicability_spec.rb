# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Record::Applicability do
  # only has records for Samsung in 2014, 2015
  let(:metric) { Card["Joe User+researched number 3"] }

  describe "event: validate_applicable_year" do
    before do
      metric.year_card.update! content: %w[2014 2015]
    end

    it "does not allow records to inapplicable years" do
      expect { create_records(metric, true) { Death_Star "1977" => "2" } }
        .to raise_error /Inapplicable Year: 1977/
    end

    it "does allows records to applicable years" do
      expect { create_records(metric, true) { Death_Star "2015" => "2" } }
        .not_to raise_error
    end
  end

  describe "event: validate_applicable_company" do
    before do
      Card["Googliest"].company_card.update! content: "Samsung"
      metric.company_group_card.update! content: "Googliest"
    end

    it "does not allow records to inapplicable years" do
      expect { create_records(metric, true) { Death_Star "1977" => "2" } }
        .to raise_error /Inapplicable Company: Death_Star/
    end

    it "does allows records to applicable years" do
      expect { create_records(metric, true) { Samsung "1977" => "2" } }
        .not_to raise_error
    end
  end
end
