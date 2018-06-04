# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::MetricAnswer::Research do
  specify "non-researchable metrics are not editable" do
    rendered = view :edit, card: "Jedi+friendliness+Death Star+1977"
    aggregate_failures "no edit form" do
      expect(rendered).to have_tag("div.card-slot.left_research_side-view") do
        without_tag :input
      end
      expect(rendered).to include "Answers to this metric cannot be researched directly."
    end
  end
end
