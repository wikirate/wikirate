def unpublished_option?
  steward? && !metric_card.unpublished
end

format :html do
  view :research_button do
    nest record_card, view: :research_button
  end

  view :input do
    card.metric_card.researchable? ? direct_to_research : not_researchable
  end

  def direct_to_research
    ["Answers are edited via the research dashboard: ", render_research_button]
  end

  def not_researchable
    "Answers to this metric cannot be researched directly. "\
    "They are calculated from other answers."
  end
end
