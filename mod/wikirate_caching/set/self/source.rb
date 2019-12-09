include_set Abstract::CachedCount

recount_trigger :type, :source, on: [:create, :delete] do |_changed_card|
  Card[:source]
end
