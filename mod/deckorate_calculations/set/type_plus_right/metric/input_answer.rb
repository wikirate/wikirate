# Answer search for a given Metric

include_set Abstract::BookmarkFiltering
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CachedCount
include_set Abstract::FullAnswerSearch

# recount number of answers for a given metric when an Answer card is
# created or deleted
recount_trigger :type, :answer, on: %i[create delete] do |changed_card|
  input_answer_and_source_fields changed_card.metric_card unless changed_card.unpublished?
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  input_answer_and_source_fields changed_card.left
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  input_answer_and_source_fields changed_card.left.metric_card
end

def self.input_answer_and_source_fields metric
  metric.depender_metrics.map do |depender|
    %i[input_answer source].map { |fld| depender.fetch fld }
  end.flatten
end

def query_hash
  { depender_metric: metric_card.name }
end

def metric_card
  @metric_card ||= left
end

format do
  delegate :metric_card, to: :card

  def export_title
    "#{metric_card.metric_title.to_name.url_key}+#{:input_answer.cardname}"
  end

  def secondary_sort_hash
    super.merge year: { value: :desc }
  end

  def default_filter_hash
    { company_name: "", metric_type: "Researched" }
  end
end
