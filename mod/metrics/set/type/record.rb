include_set Abstract::MetricChild, generation: 1
include_set Abstract::TwoColumnLayout

def answer_query
  @answer_query ||= { company_id: company_id, metric_id: metric_id }
end

def researched_answers
  @researched_answers ||= Answer.search answer_query.merge(sort_by: :year,
                                                           sort_order: :desc)
end

def count
  Answer.where(answer_query).count
end

# TODO: find better place for this
def all_years
  @all_years ||= Card.search type_id: YearID, return: :name, sort: :name, dir: :desc
end

def all_answers
  @researched_answers ||= all_years.map do |year|
    Card.fetch name.field(year), new: { type_id: Card::MetricAnswerID }
  end
end

def virtual?
  !real?
end

format do
  delegate :researched_answers, :all_answers, to: :card
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
    researched_answers.map do |a|
      nest a, view: :year_and_value
    end
  end

  view :metric_selected_option, unknown: true do
    nest metric_card, view: :thumbnail_minimal
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
    researched_answers.each_with_object("") do |a, res|
      res << CSV.generate_line([a.company, a.year, a.value])
    end
  end
end

format :json do
  def item_cards
    researched_answers
  end
end
