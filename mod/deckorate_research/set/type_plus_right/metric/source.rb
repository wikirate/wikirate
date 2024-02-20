assign_type :search

# cache # of sources on which answers for this metric (=left) are based on
include_set Abstract::SearchCachedCount
include_set Abstract::SourceSearch

def cql_content
  { referred_to_by: { right_id: SourceID, left_id: answer_relation.select(:answer_id) } }
end

def answer_relation
  AnswerQuery.new(metric_id: left.id).lookup_relation
end

# recount no. of sources on metric when citation is edited
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.left.metric_card.fetch :source
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  changed_card.left.fetch :source
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  changed_card.left.metric_card.fetch :source
end

format do
  # don't show answer sort option, because that means "total answers"
  # users are likely to interpret answers as meaning answers for current metric
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
