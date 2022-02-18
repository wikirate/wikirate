include_set Abstract::Pointer
include_set Abstract::IdPointer
include_set Abstract::MetricChild, generation: 1

# FIXME: make sure not calculated twice when updated in same act as formula
event :update_calculated_answers, :integrate_with_delay,
      on: :save, changed: :content, priority: 5, when: :content? do
  metric_card.deep_answer_update
end

def check_json_syntax
  self.content = content # trigger standardization
  super
end

def standardize_content content
  items = case content
          when Array
            items
          when (/^\s*\[/)
            JSON.parse content
          else
            items_from_simple content
          end
  items.each { |hash| hash["metric"] = standardize_item hash["metric"] }
  items.to_json
end

def items_from_simple content
  content.to_s.split(/\n+/).map do |variable|
    { "metric" => variable }
  end
end

def item_strings _args={}
  parse_content.map { |item_hash| item_hash["metric"] }
end

def export_content
  db_content
end

def input_array
  (content.present? ? parse_content : [])
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
