include_set Abstract::CachedCount

recount_trigger :type, :metric, on: [:create, :delete] do |_changed_card|
  Card[:metric]
end
