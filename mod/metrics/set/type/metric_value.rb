include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

def filtered_item_query filter={}, sort={}, paging={}
  filter[:year] = year.to_i
  FixedMetricAnswerQuery.new metric_card.id, filter, sort, paging
end

def answer
  @answer ||=
    Answer.find_by_answer_id(id) ||
    (Answer.refresh(id) && Answer.find_by_answer_id(id)) ||
    Answer.new
end



format :json do
  view :core do
    data = _render_essentials.merge(
      metric: nest(card.metric, view: :essentials),
      company: nest(card.company, view: :marks)
    )
    data[:source] = nest(card.source, view: :essentials) if card.source.present?
    data.merge(checked_by: nest(card.checked_by_card, view: :essentials, hide: :marks))
  end

  def essentials
    {
      year: card.year,
      value: card.value,
      import: card.imported?,
      comments: field_nest(:discussion, view: :core)
    }
  end
end
