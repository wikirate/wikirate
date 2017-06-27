card_accessor :value, type: :phrase
card_accessor :checked_by
card_accessor :source

include_set Abstract::MetricChild, generation: 2
include_set Abstract::Answer

event :set_metric_value_name,
      before: :set_autoname, when: :invalid_value_name? do
  new_name = %w[metric company year].map do |part|
    fetch_name_part part
  end.join "+"
  abort :failure if errors.any?
  self.name = new_name
end

def filtered_item_query filter={}, sort={}, paging={}
  filter[:year] = year.to_i
  FixedMetricAnswerQuery.new metric_card.id, filter, sort, paging
end

def fetch_name_part part
  name_part = name_part_from_field(part) || name_part_from_name(part)
  check_name_part part, name_part
end

def name_part_from_name part
  return unless send("valid_#{part}?")
  send part
end

def name_part_from_field part
  field = remove_subfield part
  return unless field && field.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end

def answer
  @answer ||=
    Answer.find_by_answer_id(id) ||
    (Answer.refresh(id) && Answer.find_by_answer_id(id)) ||
    Answer.new
end

format :json do
  view :core do
    _render_essentials.merge(
      metric: nest(card.metric, view: :essentials),
      company: nest(card.company, view: :marks),
      source: nest(card.source, view: :essentials, hide: :marks)
    ).merge(nest(card.checked_by_card, view: :essentials, hide: :marks))
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

#   {
#     (metric value card marks)
#   metric: {
#     (metric cardmarks)
#   designer: (designer cardmarks)
#   title: metric title
#   }
#   company:  { (company cardmarks) }
#   year: year
#   value: value
#   source: [
#     {source 1 cardmarks, content },
#     {source 2 cardmarks, content }
#   ],
#     import: Y/N,
#     designer assessed: Y/N
#   checks: (count)
#   comments (text)
#   }
# end
