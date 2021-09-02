# -*- encoding : utf-8 -*-

describe Card::Set::TypePlusRight::Dataset::Metric do
  let(:dataset_metrics) { Card.fetch("Evil Dataset", :metric) }

  describe "table (core view)" do
    subject { dataset_metrics.format.render_core }

    it "shows bar views of <Company>+<Dataset> cards" do
      is_expected.to have_tag(".LTYPE_RTYPE-metric-dataset.bar")
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
