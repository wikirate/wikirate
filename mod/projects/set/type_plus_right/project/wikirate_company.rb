# These Project+Company (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::ProjectScope
include_set Abstract::ProjectFilteredList
include_set Abstract::IdPointer

def item_cards_for_validation
  item_cards.sort_by(&:key)
end

# are any of the metrics associated with this project researchable for this
# user?
# @return [True/False]
def researchable_metrics?
  return false unless (metric_card = Card.fetch([project_name, :metric]))
  metric_card.item_cards.find(&:user_can_answer?)
end

def short_scope_code
  :company
end

format :html do
  def core_items_hash
    card.researchable_metrics? ? super.merge(show: :bar_middle) : super
  end
end
