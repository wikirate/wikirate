RSpec.describe Card::Set::TypePlusRight::Dataset::Company do
  def card_subject
    "Evil Dataset+Company".card
  end

  it "is not broken by company rename" do
    company_card = "SPECTRE".card
    company_id = company_card.id

    company_card.update! name: "exSPECTRE", trigger_in_action: "create_alias_upon_rename"
    alias_id = "SPECTER".card_id

    expect("exSPECTRE".card_id).to eq(company_id)
    expect(alias_id).not_to eq(company_id) # alias
    expect(card_subject.item_ids)
      .to include(company_id)
      .and not_include(alias_id)
    expect(card_subject.references_out.map(&:referee_id))
      .to include(company_id)
      .and not_include(alias_id)
  end
end
