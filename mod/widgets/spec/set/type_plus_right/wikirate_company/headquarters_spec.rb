RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Headquarters do
  let(:company_name) { "Death Star"}

  let(:hq_card) { Card.fetch "#{company_name}+headquarters", new: {} }

  def company_hq_lookup metric_id
    Answer.where(
      company_id: Card.fetch_id(company_name),
      metric_id: metric_id,
      year: "2019"
    ).first
  end

  describe "event: update_company_field_answer_lookup" do
    context "when hq card is updated" do
      def death_star_to country
        hq_card.update! content: country
      end

      it "updates direct lookup value" do
        death_star_to "Netherlands"
        metric_id = Card::Codename.id hq_card.metric_code
        expect(company_hq_lookup(metric_id).value).to eq("Netherlands")
      end

      xit "updates depender values" do
        death_star_to "Alabama (United States)"
        metric_id = Card.fetch_id "Core+Country"
        expect(company_hq_lookup(metric_id).value).to eq("United States")
      end
    end
  end
end