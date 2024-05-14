# -*- encoding : utf-8 -*-

require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  let(:company_json_url) { "http://test.host/My_Company.json" }

  let :params do
    with_api_key_for "Joe User" do |api_key|
      { card: { name: "My Company",
                type: "Company",
                subcards: { "+:open_corporates_id" => "1234567",
                            "+:headquarters" => "oc_qa" } },
        success: { format: "json" },
        api_key: api_key }
    end
  end

  describe "create Company" do
    context "with confirmed=true" do
      it "redirects to company json url" do
        get :create, params: params.merge(confirmed: true)
        assert_response 303
      end
    end

    context "without confirmed=true" do
      it "requires confirmation" do
        get :create, params: params
        assert_response 200
      end
    end
  end
end
