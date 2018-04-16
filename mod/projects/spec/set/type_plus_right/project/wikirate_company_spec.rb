# -*- encoding : utf-8 -*-

describe Card::Set::TypePlusRight::Project::WikirateCompany do
  context "when project has research metrics" do
    let(:project_companies) { Card.fetch("Evil Project", :wikirate_company) }

    it "has researchable metrics" do
      expect(project_companies).to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { project_companies.format.render_core }

      it "shows three columns" do
        is_expected.to have_tag("div.progress-bar-table") do
          with_tag "table.company-progress" do
            with_tag "td.company-column"
            with_tag "td.button-column"
            with_tag "td.progress-column"
          end
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

  context "when project only has calculated metrics" do
    let(:project_companies) do
      @project_companies ||=
        Card.fetch(project_with_only_calculated_metrics, :wikirate_company)
    end

    def project_with_only_calculated_metrics
      project = Card["organized project"]
      add_formula_and_company_to project
      project
    end

    def add_formula_and_company_to project
      project.update_attributes!(
        "+companies": { content: "Death Star" },
        "+metrics": { content: "Jedi+deadliness average" }
      )
    end

    it "have no researchable metrics" do
      expect(project_companies).not_to be_researchable_metrics
    end

    describe "table (core view)" do
      subject { project_companies.format.render_core }

      it "shows two columns" do
        is_expected.to have_tag("div.progress-bar-table") do
          with_tag "table.company-progress" do
            with_tag "td.company-column"
            with_tag "td.progress-column"
          end
        end
      end

      it "does not have the middle column" do
        is_expected.not_to have_tag("td.button-column")
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
