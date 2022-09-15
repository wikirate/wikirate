card_reader :source

format :html do
  view :research_button, unknown: true do
    research_button
  end

  def research_button year=nil, tab=nil
    return "" unless card.metric_card.researchable?

    text = card.new? ? "Research" : "Verify"

    link_to_card card, text,
                 class: "btn btn-lg btn-primary _research_answer_button",
                 path: { view: :research, year: year, tab: tab },
                 title: "Research answers for this company and metric"
  end
end
