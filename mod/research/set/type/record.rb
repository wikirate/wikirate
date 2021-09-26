format :html do
  view :research_button, cache: :never do
    return "" unless metric_card.user_can_answer?
    link_to_card card, "Research",
                 class: "btn btn-sm btn-outline-secondary",
                 path: { view: :research },
                 title: "Research answers for this company and metric"
  end
end
