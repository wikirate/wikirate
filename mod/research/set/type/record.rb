card_reader :source

format :html do
  view :research_button, unknown: true do
    research_button
  end

  def research_button year=nil
    link_to_card card, "Research",
                 class: "btn btn-sm btn-outline-secondary",
                 path: { view: :research, year: year },
                 title: "Research answers for this company and metric"
  end
end
