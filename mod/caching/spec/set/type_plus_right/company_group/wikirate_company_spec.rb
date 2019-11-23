# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::CompanyGroup::WikirateCompany do
  def card_subject
    Card.fetch "Deadliest+companies", new: {}
  end

  it_behaves_like "cached count", "Deadliest+companies", 3, 1 do
    let :add_one do
      Card["Jedi+deadliness"].create_answers true do
        Monster_Inc "1977" => 77
      end
    end
    let :delete_one do
      Card["Jedi+deadliness+SPECTRE+1977"].delete
    end
  end

  describe "#update_content_from_spec" do
    it "finds companies when there is one constraint" do
      # this is really testing whether the method is called correctly at seed time
      expect(card_subject.item_names)
        .to eq(["Death Star", "Los Pollos Hermanos", "SPECTRE"])
    end

    def constraint_class
      Card::Set::Right::Specification::Constraint
    end

    it "finds companies when there is more than one constraint" do
      spec = Card["Deadliest+specification"]
      new_constraint = constraint_class.new("Fred+dinosaurlabor", 2000, "\"yes\"")
      spec.update! content: "#{spec.content}\n#{new_constraint}"
      expect(card_subject.item_names).to eq(["Death Star"])
    end
  end
end
