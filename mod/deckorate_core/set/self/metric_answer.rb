include_set Abstract::FullAnswerSearch
include_set Abstract::Chart
include_set Abstract::CachedCount

def count
  Card::AnswerQuery.new({}).count
end

# recount answers when answer is created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |_changed_card|
  Card[:metric_answer]
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount(changed_card) { Card[:metric_answer] }
end

format :html do
  def default_sort_option
    :year
  end

  before :header do
    voo.title = "Answer Dashboard #{mapped_icon_tag :dashboard}"
    voo.variant = nil
  end

  view :titled_content do
    [field_nest(:description), render_filtered_content]
  end
end

format :json do
  def default_vega_options
    { layout: { width: 700 } }
  end
end
