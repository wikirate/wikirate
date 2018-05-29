# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::MetricAnswer::Research do
  specify "non-researchable metrics are not editable" do
    rendered = view :edit, card: "Jedi+friendliness+Death Star+1977"
    aggregate_failures "no edit form" do
      expect(rendered).not_to have_tag ("input")
      expect(rendered).and include "metric not editable"
    end
  end
end
