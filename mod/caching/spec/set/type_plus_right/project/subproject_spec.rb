# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Project::Subproject do
  describe "subprojects" do
    def create_subproject subfields={}
      subfields.reverse_merge! parent: "Evil Project"
      Card.create! name: "Daughter of Evil Project",
                   type_id: Card::ProjectID,
                   subfields: subfields
    end

    it_behaves_like "cached count", "Evil Project+subproject", 1, 1 do
      let(:add_one) { create_subproject }
      let(:delete_one) { Card["Son of Evil Project"].delete }
    end

    it "adds its metrics to parent project" do
      subproject = create_subproject metric: "Joe User+RM"
      expect(subproject.parent_project_card.metric_card.item_names).to include("Joe User+RM")
    end

    it "adds its companies to parent project" do
      new_companies = ["Google LLC", "Monster Inc"]
      subproject = create_subproject wikirate_company: new_companies.to_pointer_content
      parent_companies = subproject.parent_project_card.wikirate_company_card.item_names
      expect(parent_companies).to include(*new_companies)
    end
  end
end
