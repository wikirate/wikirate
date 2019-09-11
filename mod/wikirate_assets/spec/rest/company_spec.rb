# -*- encoding : utf-8 -*-

require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:company_json_url) { "http://test.host/My_Company.json" }

  describe "create Company" do
    it "redirects to company json url" do
      with_api_key_for "Joe User" do |api_key|
        get :create, params: { card: { name: "My Company",
                                       type: "Company",
                                       subcards: { "+:open_corporates" => "1234567",
                                                   "+:headquarters" => "oc_qa" } },
                               success: { format: "json" },
                               api_key: api_key }
      end
      assert_response 303
      # The following test success when tested alone, but it contains a badge
      # flash when run with other specs.  Commenting for now.
      # expect(response).to redirect_to(company_json_url)
    end
  end
end
