# cache # of topics metric (=_left) is tagged with
include_set Abstract::CachedCount

def recount
  item_names.size
end

def count
  cached_count
end

recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  changed_card
end
