
def inheritance_formula
  item_names.map do |item|
    "{{#{item} | not_researched: false}}"
  end.join " || "
end

format :html do
  def default_item_view
    :mini_bar
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  view :ancestor_core do
    wrap_with :h6 do
      ["Inherit from ancestor (in order of precedence):",
       raw(ancestor_thumbnails.join("<div>OR</div>"))]
    end
  end

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
