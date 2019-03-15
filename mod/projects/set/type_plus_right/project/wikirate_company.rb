# These Project+Company (type plus right) cards refer to the list of
# all companies on a given project.

# @return [Card::Name]
def project_name
  name.left_name
end

# @return [Array] all of this card's items that refer to a valid company
def valid_company_cards
  @valid_company_cards ||=
    item_cards.sort_by(&:key).select do |company|
      company.type_id == WikirateCompanyID
    end
end

# @return [Array] a list of Company+Project cards (ltype rtype) that connect
# each of this card's company items to its project.
def all_company_project_cards
  valid_company_cards.map do |company|
    company_project_card company
  end
end

# @return [Card] a single Company+Project card (ltype rtype)
def company_project_card company_card
  Card.fetch company_card.name, project_name, new: {}
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
    voo.edit = :content_inline
    voo.items.delete :view # reset tab_nest
  end

  view :core do
    items_hash = { view: :bar }
    items_hash[:hide] = :bar_middle unless card.researchable_metrics?
    nest Card.fetch(card.name, :project), view: :content, items: items_hash
  end
end
