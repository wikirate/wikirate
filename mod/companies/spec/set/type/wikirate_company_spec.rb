RSpec.describe Card::Set::Type::WikirateCompany do
  let(:company_card) { Card["Death Star"] }

  it "shows the link for view \"missing\"" do
    html = render_card :unknown, type_id: Card::WikirateCompanyID,
                                 name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateCompanyID,
                                          name: "non-existing-card"))
  end

  describe "creating company with post request", type: :controller do
    routes { Decko::Engine.routes }
    let(:api_key) { "asdfasf98as8238ruisdsd" }

    before do
      @controller = CardController.new
      Card::Auth.as_bot do
        Card["Joe Admin", :account, :api_key].update! content: api_key
      end
    end

    it "creates company" do
      post :create, params: { card: { name: "new company",
                                      type: "Company",
                                      subcards: { "+:open_corporates" => "C0806592",
                                                  "+:headquarters" => "us_ca" } },
                              success: { format: :json },
                              api_key: api_key }
      expect_card("new company")
        .to exist
        .and have_a_field(:open_corporates).with_content("C0806592")
        .and have_a_field(:headquarters).with_content("[[California (United States)]]")
    end
  end

  describe "renaming company" do
    def rename_company!
      company_card.update! name: "Life Star"
    end

    it "refreshes all answers" do
      rename_company!
      expect(Answer.where(company_id: "Death Star".card_id).count).to eq(0)
    end
  end

  describe "deleting company" do
    it "deletes all answers", as_bot: true do
      company_id = company_card.id
      company_card.delete!
      expect(Answer.where(company_id: company_id).count).to eq(0)
      expect(Relationship.where(subject_company_id: company_id).count).to eq(0)
      expect(Relationship.where(object_company_id: company_id).count).to eq(0)
    end
  end

  describe "inapplicable_metrics" do
    let(:metric) { Card["Jedi+cost of planets destroyed"] }

    before do
      Card::Auth.as_bot do
        metric.company_group_card.update! content: "Deadliest"
        # restricts metric to Death Star, Los Pollos Hermanos, and SPECTRE
      end
    end

    it "finds metrics that exclude it" do
      expect(Card["Samsung"].inapplicable_metric_ids).to eq([metric.id])
    end

    it "does not finds metrics that include it" do
      expect(Card["Death Star"].inapplicable_metric_ids).to eq([])
    end
  end
end
