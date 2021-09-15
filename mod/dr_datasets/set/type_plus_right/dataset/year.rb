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
    filtering(".RIGHT-answer ._filter-widget") do
      wrap_with :div, class: "pointer-list" do
        filterable_years
      end
    end
  end

  def filterable_years
    card.item_names.map do |year|
      filterable({ year: year }, class: "pointer-item item-name") { year }
    end.join ", "
  end
end
