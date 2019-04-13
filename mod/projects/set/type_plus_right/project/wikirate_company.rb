# These Project+Company (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::ProjectScope

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

format :html do
  def editor
    :filtered_list
  end

  def default_item_view
    :thumbnail_no_link
  end

  def filter_card
    Card.fetch :wikirate_company, :browse_company_filter
  end

  before :menued do
    voo.edit = :inline
    voo.items.delete :view # reset tab_nest
  end

  view :core do
    items_hash = { view: :bar }
    items_hash[:show] = :bar_middle if card.researchable_metrics?
    nest Card.fetch(card.name, :project), view: :content, items: items_hash
  end
end
