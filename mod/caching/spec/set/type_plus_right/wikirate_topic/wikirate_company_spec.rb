# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::WikirateCompany do
  it_behaves_like "cached count", ["Taming", :wikirate_company], 4, 1 do
    let :add_one do
      Card.fetch("Joe User+researched+topics", new: {}).add_item! "Taming"
    end
    let :delete_one do
      Card["Joe User+researched number 3+topics"].drop_item! "Taming"
    end
  end

  it_behaves_like "cached count", ["Force", :wikirate_company], 4, 1 do
    let :add_one do
      Card["Jedi+disturbances in the Force"].create_values true do
        Samsung "1977" => "no"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force+SPECTRE+2000"].delete
    end
  end

  describe "#company_ids_by_metric_count" do
    it "builds an array of arrays of companies/counts" do
      result = Card.fetch("Taming+company").company_ids_by_metric_count
      result_ids = result.map { |company_id, _count| company_id }.compact.sort
      expected = %w[samsung death_star monster_inc slate_rock_and_gravel_company]
      expected_ids = expected.map { |name| Card.fetch_id name }.sort
      expect(result_ids).to eq(expected_ids)
    end
  end
end
