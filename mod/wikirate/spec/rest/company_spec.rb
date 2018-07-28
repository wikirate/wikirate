# -*- encoding : utf-8 -*-
require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:company_json_url) { "http://test.host/My_Company.json" }

  describe "create Company" do
    it "redirects to company json url" do
      with_token_for "Joe User" do |token|
        get :create, params: { card: { name: "My Company",
                                       type: "Company",
                                       subcards: { "+:open_corporates" => "1234567",
                                                   "+:headquarters" => "oc_qa" } },
                               success: { format: "json" },
                               token: token }
      end
      expect(response).to redirect_to(company_json_url)
    end
  end
end
