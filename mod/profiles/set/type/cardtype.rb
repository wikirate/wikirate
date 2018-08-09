include_set Abstract::ReportQueries

def item_search_card
  fetch trait: [:type, :by_name]
end

format do
  before :header do
    voo.variant = :plural
  end
end

format :html do
  def core_with_listing
    output [field_nest(:description),
            render_add_button,
            items_in_rows]
  end

  def items_in_rows
    nest card.item_search_card, items: { view: :bar }
  end
end
