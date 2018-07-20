describe Card::Set::Type::WikirateCompany do
  it "shows the link for view \"missing\"" do
    html = render_card :missing, type_id: Card::WikirateCompanyID, name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateCompanyID, name: "non-existing-card"))
  end


  describe "creating company with post request", type: :controller do
    routes { Decko::Engine.routes }
    before do
      @controller = CardController.new
      #login_as "joe_user"
    end

    let(:token) { Card["Joe Admin",:account, :token] }

    it "creates company" do
      post :create, params: { card: { name: "new company",
                                      subcards: { "+:open_corporates" => "C0806592",
                                                  "+:headquarters" => "us_ca" } },
                              success: { format: :json },
                              token: token.content }
      expect_card("new company")
        .to exist
        .and have_a_field(:open_corporates).with_content("C0806592")
        .and have_a_field(:headquarters).with_content("[[California (United States)]]")
    end
  end
end
