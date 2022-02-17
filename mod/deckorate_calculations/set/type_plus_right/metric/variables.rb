include_set Abstract::IdPointer

def standardize_content content
  items = content.match?(/^\s*\[/) ? JSON.parse(content) : items_from_simple(content)

  puts "standardize_content: #{items}"

  items.map { |hash| hash["metric"] = standardize_item hash["metric"] }.to_json
end

def items_from_simple content
  content.to_s.split(/\n+/).map do |variable|
    { "metric" => variable }
  end
end

def raw_item_strings content
  JSON.parse(content).map { |item_hash| item_hash["metric"] }
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
