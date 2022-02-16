include_set Abstract::IdPointer

def standardize_content value
  return value if value.match?(/^\s*\{/) # already JSON

  value.to_s.split(/\n+/).each_with_object({}) do |variable, hash|
    hash[standardize_item(variable)] = {}
  end.to_json
end

def export_content
  db_content
end

format :html do
  def input_type
    :filtered_list
  end

  def default_item_view
    :bar
  end

  def filter_card
    :metric.card
  end

  view :descendant_formula do
    wrap do
      [
        wrap_with(:h6) { "Inherit from ancestor (in order of precedence):" },
        render_menu,
        raw(ancestor_thumbnails.join("<div>OR</div>"))
      ]
    end
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
