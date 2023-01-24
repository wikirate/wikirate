include_set Abstract::CodeContent

# include_set Abstract::SolidCache, cached_format: :html
#
# cache_expire_trigger Card::Set::All::Base do |_changed_card|
#   Card[:homepage] if Codename.exist? :homepage
# end

def new_relic_label
  "home"
end

format :html do
  def layout_name_from_rule
    :deckorate_minimal_layout
  end

  %i[core involved counts benchmarks delta search].each do |view|
    view view, template: :haml
  end

  def involved_links
    {
      "Join a project": "/:project",
      "Find our latest events": "",
      "Host your own project": "/new/:project",
      "Sign up": "/new/:signup"
    }
  end

  def edit_fields
    count_categories.map { |c| [[c, :header], { absolute: true }] } +
      [[%i[designer featured], { absolute: true }],
       [%i[search featured], { absolute: true }],
       :metric]
  end

  def count_categories
    %i[wikirate_company metric metric_answer source]
  end

  # def benchmark_metric_card
  #   delta_metric_card.variables_card.first_card
  # end

  def delta_metric_card
    %i[homepage metric].card&.first_card
  end

  def delta_answers
    return [] unless (metric = delta_metric_card)

    metric.metric_answer_card.search limit: 6
  end
end
