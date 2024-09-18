# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::CompanyGroup::Company do
  def card_subject
    Card.fetch "Deadliest+companies", new: {}
  end

  it_behaves_like "cached count", "Deadliest+companies", 3, 1 do
    let :add_one do
      create_answers "Jedi+deadliness", true do
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
      expect(card_subject.item_names.sort)
        .to eq(["Death Star", "Los Pollos Hermanos", "SPECTRE"])
    end

    it "finds companies when there is more than one constraint" do
      spec = "Deadliest+specification".card
      spec.update! content: spec.constraints.push(metric_id: "Fred+dinosaurlabor",
                                                  year: 2000,
                                                  value: "yes")
      expect(card_subject.item_names).to eq(["Death Star"])
    end
  end
end
