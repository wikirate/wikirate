card_reader :source

format :html do
  view :research_button, unknown: true do
    research_button
  end

  def research_button year=nil, tab=nil
    contextualizing_research_button do |text|
      link_to_card card, text,
                   class: "btn btn-secondary _research_answer_button",
                   path: { view: :research, year: year, tab: tab },
                   target: "_research_page",
                   title: "Research/Review answers for this company and metric"
    end
  end

  def contextualizing_research_button
    return "" unless card.metric_card.researchable?

    yield(card.new? ? "Research" : "Review")
  end
end
