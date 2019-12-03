include_set Abstract::CachedCount

def count
  Answer.count
end

recount_trigger :type, :metric_answer, on: [:create, :delete] do |_changed_card|
  Card[:metric_answer]
end
