RSpec.describe Card::Set::TypePlusRight::Company::Headquarters do
  let(:company_name) { "Death Star" }

  let(:hq_card) { Card.fetch "#{company_name}+headquarters", new: {} }

  def company_hq_lookup metric
    ::Answer.where(
      company_id: company_name.card_id,
      metric_id: metric.card_id,
      year: "2019"
    ).first
  end

  def death_star_to country
    hq_card.update! content: country
  end

  describe "event: update_company_field_answer_lookup" do
    context "when hq card is created" do
      it "updates direct lookup value" do
        death_star_to "Netherlands"
        expect(company_hq_lookup(hq_card.metric_code).value).to eq("Netherlands")
      end

      it "updates depender values" do
        death_star_to "Alabama (United States)"
        expect(company_hq_lookup("Core+Country").value).to eq("United States")
        expect(company_hq_lookup("Core+ILO Region").value).to eq("Americas")
      end
    end

    context "when hq card is deleted" do
      let(:company_name) { "Google LLC" }

      it "removes direct lookup value and depender values", as_bot: true do
        hq_card.delete!
        expect(company_hq_lookup(hq_card.metric_code)).to be_nil
        expect(company_hq_lookup("Core+Country")).to be_nil
      end
    end
  end
end
