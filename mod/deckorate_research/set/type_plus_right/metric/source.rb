assign_type :search_type

# cache # of sources on which answer for this metric (=left) are based on
include_set Abstract::SearchCachedCount
include_set Abstract::SourceSearch

def cql_content
  { referred_to_by: { right: :source, left_id: answer_relation.select(:answer_id) } }
end

def answer_relation
  query_key = left.calculated? ? :depender_metric : :metric_id
  AnswerQuery.new(query_key => left.id).lookup_relation
end

# NOTE: (indirect) sources of calculated metrics are handled in Metric+Input Answer

# recount no. of sources on metric when citation is edited
recount_trigger :type_plus_right, :answer, :source do |changed_card|
  changed_card.left.metric_card.fetch :source
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  changed_card.left.fetch :source
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  changed_card.left.metric_card.fetch :source
end

private

format do
  # don't show answer sort option, because that means "total answers"
  # users are likely to interpret answers as meaning answers for current metric
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
