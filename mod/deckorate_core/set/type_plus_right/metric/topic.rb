# cache # of topics metric (=_left) is tagged with
include_set Abstract::CachedCount

def ok_item_types
  :topic
end

recount_trigger :type_plus_right, :metric, :topic do |changed_card|
  changed_card unless changed_card&.left&.trash
end
