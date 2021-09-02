# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Dataset::WikirateCompany do
  context "when dataset has research metrics" do
    let(:dataset_companies) { Card.fetch("Evil Dataset", :wikirate_company) }

    it "has researchable metrics" do
      expect(dataset_companies).to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { dataset_companies.format.render_core }

      it "shows bar views of <Company>+<Dataset> cards" do
        is_expected.to have_tag(".LTYPE_RTYPE-company-dataset.bar") do
          with_tag ".bar-middle"
        end
      end

      it "includes research buttons" do
        is_expected.to have_tag("a.research-answer-button")
      end

      it "includes progress bars" do
        is_expected.to have_tag("div.progress") do
          with_tag "div.progress-bar"
        end
      end
    end
  end

  context "when dataset only has calculated metrics" do
    let(:dataset_companies) do
      @dataset_companies ||=
        Card.fetch(dataset_with_only_calculated_metrics, :wikirate_company)
    end

    def dataset_with_only_calculated_metrics
      dataset = Card["organized dataset"]
      add_formula_and_company_to dataset
      dataset
    end

    def add_formula_and_company_to dataset
      dataset.update!(
        "+companies": { content: "Death Star" },
        "+metrics": { content: "Jedi+deadliness average" }
      )
    end

    it "have no researchable metrics" do
      expect(dataset_companies).not_to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { dataset_companies.format.render_core }

      it "shows bar views of <Company>+<Dataset> cards" do
        is_expected.to have_tag(".LTYPE_RTYPE-company-dataset.bar")
      end

      it "does not have the middle column" do
        is_expected.not_to have_tag(".bar-middle")
      end

      it "does not include research buttons" do
        is_expected.not_to have_tag("a.research-answer-button")
      end

      it "does include progress bars" do
        is_expected.to have_tag("div.progress") do
          with_tag "div.progress-bar"
        end
      end
    end
  end
end
