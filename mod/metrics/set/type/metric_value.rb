include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

event :flash_success_message, :finalize, on: :create do
  msg =
    format(:html).alert :success, true, false, class: "text-center" do
      <<-HTML
        <p>Success! To research another answer select a different metric or year.</p>
      HTML
    end
  success.flash msg
end

def filtered_item_query filter={}, sort={}, paging={}
  filter[:year] = year.to_i
  FixedMetricAnswerQuery.new metric_card.id, filter, sort, paging
end

def answer
  @answer ||= existing_answer || Answer.new
end

def existing_answer
  return unless id
  Answer.find_by_answer_id(id) ||
    (Answer.refresh(id) && Answer.find_by_answer_id(id))
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
