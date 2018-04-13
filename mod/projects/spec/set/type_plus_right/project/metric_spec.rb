# -*- encoding : utf-8 -*-

describe Card::Set::TypePlusRight::Project::Metric, "metric list on project" do
  let(:project_metrics) { Card.fetch("Evil Project", :metric) }

  describe "table (core view)" do
    subject { project_metrics.format.render_core }

    it "shows two columns" do
      is_expected.to have_tag("div.progress-bar-table") do
        with_tag "table.metric-progress" do
          with_tag "td.metric-column"
          with_tag "td.progress-column"
        end
      end
    end

    it "does not include research buttons" do
      is_expected.not_to have_tag("a.research-answer-button")
    end

    it "includes progress bars" do
      is_expected.to have_tag("div.progress") do
        with_tag "div.progress-bar"
      end
    end
  end
end
