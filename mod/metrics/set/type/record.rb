include_set Abstract::MetricChild, generation: 1
include_set Abstract::TwoColumnLayout

card_accessor :metric_answer

event :update_lookups_on_record_rename, :finalize, changed: :name, on: :update do
  metric_answer_card.search.each(&:refresh)
end

def virtual?
  new?
end

format do
  delegate :answers, to: :card
end

format :html do

  def tab_list
    %i[metric wikirate_company]
  end

  def tab_options
    tab_list.each_with_object({}) do |tab, hash|
      hash[tab] = { count: nil, label: tab.cardname }
    end
  end

  view :data do
    field_nest :metric_answer, view: :filtered_content
  end

  view :rich_header do
    [nest(card.metric_card, view: :shared_header),
     nest(card.company_card, view: :shared_header)]
  end

  view :metric_tab do
    nest card.metric_card, view: :details_tab
  end

  view :wikirate_company_tab do
    nest card.company_card, view: :details_tab
  end

  view :research_button, cache: :never do
    return "" unless metric_card.user_can_answer?
    link_to_card card, "Research",
                 class: "btn btn-sm btn-outline-secondary",
                 path: { view: :research },
                 title: "Research answers for this company and metric"
  end
end

format :csv do
  view :core do
    answers.each_with_object("") do |a, res|
      res << CSV.generate_line([a.company, a.year, a.value])
    end
  end
end

format :json do
  def item_cards
    answers
  end
end
