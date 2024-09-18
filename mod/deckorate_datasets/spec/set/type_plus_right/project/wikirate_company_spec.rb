# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Project::Company do
  context "when dataset has research metrics" do
    let(:project_companies) { Card.fetch("Evil Project", :company) }

    it "has researchable metrics" do
      expect(project_companies).to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { project_companies.format.render_core }

      it "shows bar views of <Company>+<Project> cards" do
        is_expected.to have_tag(".TYPE-company.bar") do
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
    let :project_companies do
      @project_companies ||=
        Card.fetch(project_with_only_calculated_metrics, :company)
    end

    def project_with_only_calculated_metrics
      add_formula_and_company_to Card["empty dataset"]
      Card.create name: "empty project",
                  type: :project,
                  fields: { dataset: { type: :pointer, content: "empty dataset" } }
    end

    def add_formula_and_company_to dataset
      dataset.update!(
        "+companies": { content: "Death Star" },
        "+metrics": { content: "Jedi+deadliness average" }
      )
    end

    it "have no researchable metrics" do
      expect(project_companies).not_to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { project_companies.format.render_core }

      it "shows bar views of <Company>+<Project> cards" do
        is_expected.to have_tag(".TYPE-company.bar")
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
