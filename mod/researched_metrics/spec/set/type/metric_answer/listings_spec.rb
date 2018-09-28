# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MetricAnswer::Listings do
  # TODO: move this to where humanized_number is actually defined.
  describe "#humanized_number" do
    def humanize number
      Card["Jedi+deadliness+Death Star+1977"].format.humanized_number(number)
    end

    specify do
      expect(humanize("1_000_001")).to eq "1M"
    end
    specify do
      expect(humanize("0.00000123345")).to eq "0.00000123"
    end
    specify do
      expect(humanize("0.001200")).to eq "0.0012"
    end
    specify do
      expect(humanize("123.4567")).to eq "123.5"
    end
  end

  describe "view :concise" do
    def concise_answer_for metric_title
      render_view :concise, name: "#{metric_title}+Sony Corporation+2010"
    end

    context "with multi category metric" do
      subject { concise_answer_for "Joe User+big multi" }

      it "has comma separated list of values" do
        is_expected.to have_tag "span.metric-value", "1, 2"
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year", /2010/
      end
      it "has options" do
        is_expected.to have_selector title: '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11'
      end
    end

    context "with single category metric" do
      subject { concise_answer_for "Joe User+big single" }

      it "has value" do
        is_expected.to have_tag "span.metric-value", "4"
      end
      it "has correct year" do
        is_expected.to have_tag "span.metric-year", /2010/
      end
      it "has options" do
        is_expected.to have_selector title: '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11'
      end
    end
  end
end
