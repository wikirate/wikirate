# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Dataset::DataSubset do
  describe "data_subsets" do
    def create_data_subset fields={}
      fields.reverse_merge! parent: "Evil Dataset"
      Card.create! name: "Daughter of Evil Dataset",
                   type: :dataset,
                   fields: fields
    end

    it_behaves_like "cached count", "Evil Dataset+data_subset", 1, 1 do
      let(:add_one) { create_data_subset }
      let(:delete_one) { Card["Son of Evil Dataset"].delete }
    end

    it "adds its metrics to parent dataset" do
      new_metric = "Joe User+RM"
      data_subset = create_data_subset metric: new_metric
      parent_metrics = data_subset.parent_dataset_card.metric_card.item_names
      expect(parent_metrics).to include(new_metric)
    end

    it "adds its companies to parent dataset" do
      new_companies = ["Google LLC", "Monster Inc"]
      data_subset = create_data_subset company: new_companies.to_pointer_content
      parent_companies = data_subset.parent_dataset_card.company_card.item_names
      expect(parent_companies).to include(*new_companies)
    end

    it "prevents removal of companies from parent" do
      create_data_subset company: "Death Star"
      expect { Card["Evil Dataset+companies"].update_attributes! content: "SPECTRE" }
        .to raise_error(/cannot be removed: Death Star/)
    end

    it "prevents deletion of parent trait card" do
      create_data_subset company: "Death Star"
      expect { Card["Evil Dataset+companies"].delete! }
        .to raise_error(
          /cannot be deleted, because there are data_subsets with at least one Company/
        )
    end
  end
end
