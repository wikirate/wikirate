# cache # of sources on which answers for this metric (=left) are based on
include_set Abstract::SearchCachedCount

def wql_hash
  { referred_to_by: { right_id: Card::SourceID, left_id: [:in] + answer_ids } }
end

def skip_search?
  answer_ids.blank?
end

def answer_ids
  Answer.where(metric_id: left.id).where.not(answer_id: :nil).pluck :answer_id
end

# recount no. of sources on metric
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.left.metric_card.fetch trait: :source
end
