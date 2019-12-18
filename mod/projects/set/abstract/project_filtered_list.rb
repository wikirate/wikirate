format :html do
  def input_type
    :filtered_list
  end

  def default_item_view
    card.num > 100 ? :name : :thumbnail_no_link
  end

  # card for searching/filtering through all companies/metrics when adding new items
  def filter_card
    Card.fetch card.scope_code, :"browse_#{card.short_scope_code}_filter"
  end

  # card for searching/filtering through companies/metrics attached to project
  def search_card
    Card.fetch card.project_name, :"#{card.short_scope_code}_search"
  end

  before :menued do
    voo.edit = :inline
    voo.items.delete :view # reset tab_nest
  end

  def core_items_hash
    { view: :bar, hide: %i[project_header bar_nav] }
  end

  view :core do
    nest search_card, view: :filtered_content, items: core_items_hash
  end
end
