RSpec.describe Card::Set::Type::WikirateCompany do
  it "shows the link for view \"missing\"" do
    html = render_card :missing, type_id: Card::WikirateCompanyID,
                                 name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateCompanyID,
                                          name: "non-existing-card"))
  end

  describe "creating company with post request", type: :controller do
    routes { Decko::Engine.routes }
    before { @controller = CardController.new }

    let(:token) do
      Card::Auth.as_bot do
        Card["Joe Admin", :account, :token].update! content: "abcd"
        "abcd"
      end
    end

    it "creates company" do
      post :create, params: { card: { name: "new company",
                                      type: "Company",
                                      subcards: { "+:open_corporates" => "C0806592",
                                                  "+:headquarters" => "us_ca" } },
                              success: { format: :json },
                              token: token }
      expect_card("new company")
        .to exist
        .and have_a_field(:open_corporates).with_content("C0806592")
        .and have_a_field(:headquarters).with_content("[[California (United States)]]")
    end
  end

  describe "renaming company" do
    let(:company_card) { Card["Death Star"] }

    def rename_company!
      company_card.update! name: "Life Star"
    end

    it "refreshes all answers" do
      rename_company!
      expect(Answer.where(company_name: "Death Star").count).to eq(0)
    end

  end
end
