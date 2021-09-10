
# cache # of sources on which answers for this metric (=left) are based on
include_set Abstract::SearchCachedCount
include_set Abstract::SourceFilter

def cql_content
  { referred_to_by: { right_id: SourceID, left_id: [:in] + answer_ids } }
end

def skip_search?
  answer_ids.blank?
end

# turn query caching off because cql_hash varies
def cache_query?
  false
end

def answer_ids
  ::Answer.where(metric_id: left.id)
          .where.not(answer_id: nil)
          .where("answers.unpublished is not true")
          .pluck :answer_id
end

# recount no. of sources on metric when citation is edited
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.left.metric_card.fetch :source
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    changed_card.left.metric_card.fetch :source
  end
end

format do
  # don't show answer sort option, because that means "total answers"
  # users are likely to interpret answers as meaning answers for current metric
  def sort_options
    super.reject { |_k, v| v == :answer }
  end
end
