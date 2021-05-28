include_set Abstract::CachedCount

def count
  Answer.count
end

# recount answers when answer is created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |_changed_card|
  Card[:metric_answer]
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  return if changed_card.left&.action&.in? %i[create delete]

  Card[:metric_answer]
end
