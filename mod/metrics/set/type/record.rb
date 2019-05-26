include_set Abstract::MetricChild, generation: 1
include_set Abstract::TwoColumnLayout

def all_answers
  @result ||= Answer.search(company_id: company_id,
                            metric_id: metric_id,
                            sort_by: :year,
                            sort_order: :desc)
end

def virtual?
  !real?
end

# def value year
#   answer_where(year).pluck(:value).first
# end
#
# def answer year
#   answer_where(year).first
# end
#
# def answer_where year
#   Answer.where record_id: id, year: year.to_i
# end

format do
  delegate :all_answers, to: :card
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
      [render_years_and_values, add_answer_button]
    end
  end

  def add_answer_button
    return "" unless metric_card.user_can_answer?
    link_to_card :research_page, "Research answer",
                 class: "btn btn-sm btn-primary margin-12",
                 path: { metric: card.metric,
                         company: card.company },
                 title: "Research answers for this company and metric"
  end

  view :metric_option, template: :haml, unknown: true

  # NOCACHE because item search
  view :years_and_values, cache: :never do
    all_answers.map do |a|
      nest a, view: :year_and_value_pretty_link
    end
  end

  view :metric_selected_option, unknown: true do
    nest metric_card, view: :selected_option
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
    all_answers.each_with_object("") do |a, res|
      res << CSV.generate_line([a.company, a.year, a.value])
    end
  end
end

format :json do
  def item_cards
    all_answers
  end
end
