# cache # of topics metric (=_left) is tagged with
include_set Abstract::CachedCount

def recount
  item_names.size
end

def count
  cached_count
end

recount_trigger Metric::WikirateTopic do |changed_card|
  changed_card
end




