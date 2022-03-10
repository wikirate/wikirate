format :html do
  view :descendant_core do
    [wrap_with(:h6) { "Inherit from ancestor (in order of precedence):" },
     raw(ancestor_thumbnails.join("<div>OR</div>"))]
  end

  def descendant_input
    filtered_list_input
  end

  def descendant_filtered_item_view
    implicit_item_view
  end

  def descendant_filtered_item_wrap
    :filtered_list_item
  end

  private

  def ancestor_thumbnails
    card.item_cards.map do |item_card|
      nest_item(item_card, view: :formula_thumbnail) do |rendered, item_view|
        wrap_ancestor { wrap_item rendered, item_view }
      end
    end
  end

  def wrap_ancestor
    wrap_with(:div, class: "clearfix") { yield }
  end
end
