# These Dataset+Company (type plus right) cards refer to the list of
# all companies on a given dataset.

include_set Abstract::DatasetScope
include_set Abstract::IdPointer

def item_cards_for_validation
  item_cards.sort_by(&:key)
end
