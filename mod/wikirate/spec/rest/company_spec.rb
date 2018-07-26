RSpec.describe CardController, type: :controller do
  routes { Decko::Engine.routes }

  include Capybara::DSL

  describe "create Company" do
    before do
      with_token_for "Joe User" do |token|
        get :create, params: { card: { name: "My Company",
                                       type: "Company",
                                       subcards: { "+:open_corporates" => "1234567",
                                                   "+:headquarters" => "oc_qa" } },
                               success: { format: "json" },
                               token: token }
      end
    end

    it "returns a success code" do
      expect(response.status).to eq(200)
    end

    it "returns JSON" do
      expect(response.header["Content-Type"]).to eq("json/application")
    end

    it "returns JSON with a company id" do
      json = JSON.parse response.body
      expect json[:card][:id].to be_a(Integer)
    end

    def with_token_for usermark
      yield Card[usermark].account.reset_token
    end

  end
end
