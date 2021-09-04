include_set Abstract::MetricChild, generation: 1
include_set Abstract::TwoColumnLayout

event :update_lookups_on_record_rename, :finalize, changed: :name do
  answer_relation.each(&:refresh)
end

def answer_relation
  Answer.where(company_id: company_id, metric_id: metric_id)
        .where "answers.unpublished is not true"
end

def answers
  @answers ||= answer_relation.sort(year: :desc)
end

def count
  answer_relation.count
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

  view :rich_header do
    [nest(card.metric_card, view: :shared_header),
     nest(card.company_card, view: :shared_header)]
  end

  view :data do
    wrap_with :div, class: "p-3" do
      [render_years_and_values, render_research_answer_button]
    end
  end

  view :research_answer_button, cache: :never do
    return "" unless metric_card.user_can_answer?
    link_to_card :research_page, "Research",
                 class: "btn btn-sm btn-outline-secondary",
                 path: { metric: card.metric, company: card.company },
                 title: "Research answers for this company and metric"
  end

  # NOCACHE because item search
  view :years_and_values, cache: :never, unknown: true do
    card.answers.map do |a|
      nest a, view: :year_and_value
    end
  end

  view :metric_tab do
    nest card.metric_card, view: :details_tab
  end

  view :wikirate_company_tab do
    nest card.company_card, view: :details_tab
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
