RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Headquarters do
  let(:company_name) { "Death Star"}

  let(:hq_card) { Card.fetch "#{company_name}+headquarters", new: {} }

  let :company_hq_lookup do
    Answer.where(
      company_id: Card.fetch_id(company_name),
      metric_id: Card::Codename.id(hq_card.metric_code),
      year: "2019"
    ).first
  end

  describe "event: update_company_field_answer_lookup" do
    it "updates lookup value when hq card is updated" do
      hq_card.update! content: "Netherlands"
      expect(company_hq_lookup.value).to eq("Netherlands")
    end
  end
end