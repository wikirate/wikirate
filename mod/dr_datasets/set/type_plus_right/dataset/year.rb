include_set Abstract::Table
include_set Abstract::PointerCachedCount
include_set Abstract::DatasetScope
include_set Abstract::Filterable

def hereditary_field?
  false
end

def item_cards_for_validation
  item_cards.sort_by(&:name).reverse
end

format :html do
  def input_type
    :multiselect
  end

  view :core do
    filtering(".RIGHT-answer ._filter-widget") { super() }
  end

  def wrap_item rendered, item_view
    filterable({ year: rendered }, class: "pointer-item item-#{item_view}") do
      rendered
    end
  end
end
