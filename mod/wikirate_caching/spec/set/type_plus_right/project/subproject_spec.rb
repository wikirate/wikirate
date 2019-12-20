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
      new_metric = "Joe User+RM"
      subproject = create_subproject metric: new_metric
      parent_metrics = subproject.parent_project_card.metric_card.item_names
      expect(parent_metrics).to include(new_metric)
    end

    it "adds its companies to parent project" do
      new_companies = ["Google LLC", "Monster Inc"]
      subproject = create_subproject wikirate_company: new_companies.to_pointer_content
      parent_companies = subproject.parent_project_card.wikirate_company_card.item_names
      expect(parent_companies).to include(*new_companies)
    end

    it "prevents removal of companies from parent" do
      create_subproject wikirate_company: "Death Star"
      expect { Card["Evil Project+companies"].update_attributes! content: "SPECTRE" }
        .to raise_error(/cannot be removed: Death Star/)
    end

    it "prevents deletion of parent trait card" do
      create_subproject wikirate_company: "Death Star"
      expect { Card["Evil Project+companies"].delete! }
        .to raise_error(
          /cannot be deleted, because there are subprojects with at least one Company/
        )
    end
  end
end
