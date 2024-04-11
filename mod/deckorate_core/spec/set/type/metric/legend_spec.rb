RSpec.describe Card::Set::Type::Metric::Legend do
  context "with category metrics" do
    def card_subject
      Card["Joe User+small single"]
    end

    specify "view: legend" do
      expect(format_subject(:base).category_legend).to eq("1, 2, 3")
      # expect(format_subject(:html).category_legend).to have_tag("span.metric-legend") do
      #   with_tag "span.small", /1, 2, 3/
      # end
    end
  end
end
