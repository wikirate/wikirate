card_reader :source

format :html do
  view :research_button, unknown: true do
    research_button
  end

  def research_button year=nil, tab=nil
    return "" unless card.metric_card.researchable?

    link_to_card card, research_button_text,
                 class: "btn btn-secondary _research_answer_button _over-card-link",
                 path: { view: :research, year: year, tab: tab },
                 target: "_research_page",
                 title: "Research/Review answers for this company and metric"
  end

  def research_button_text
    card.new? ? "Research" : "Review"
  end
end
