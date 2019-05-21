include_set Abstract::MetricChild, generation: 1

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

format :html do
  delegate :all_answers, to: :card

  view :core do
    [
      nest(card.metric_card, view: :rich_header),
      nest(card.company_card, view: :rich_header),
      all_answers.map do |answer|
        nest answer, view: :bar
      end,
      add_answer_button
    ]
  end

  def add_answer_button
    return "" unless metric_card.user_can_answer?
    link_to_card :research_page, "Research answer",
                 class: "btn btn-sm btn-primary margin-12",
                 path: { view: "slot_machine", metric: card.metric, company: card.company },
                 title: "Research answer for another year"
  end

  # NOCACHE because item search
  view :metric_option, template: :haml, unknown: true

  view :years_and_values, cache: :never do
    output do
      all_answers.map do |a|
        nest a, view: :year_and_value
      end
    end
  end

  view :metric_selected_option, unknown: true do
    nest metric_card, view: :selected_option
  end
end

format :csv do
  view :core do
    res = ""
    all_answers.each do |a|
      res += CSV.generate_line [a.company, a.year, a.value]
    end
    res
  end
end

format :json do
  def item_cards
    card.all_answers
  end
end
