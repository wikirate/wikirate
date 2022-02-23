format :html do
  view :descendant_core do
    wrap do
      [render_header(title: "Formula"),
       wrap_with(:h6) { "Inherit from ancestor (in order of precedence):" },
       render_menu,
       raw(ancestor_thumbnails.join("<div>OR</div>"))]
    end
  end

  def descendant_input
    filtered_list_input
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
