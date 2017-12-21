include_set Type::Pointer
include_set Abstract::Variable
include_set Abstract::Table

def metric_card
  left
end

def metric_card_name
  name.left_name
end

def formula_card
  metric_card.fetch trait: :formula
end

def content
  @content ||= db_content.present? ? db_content : formula_card.input_names
end

def input_metric_name variable
  index = variable_index variable
  input_metric_name_by_index index if index
end

def input_metric_name_by_index index
  item_cards.fetch(index, nil).name
end

format :html do
  def default_item_view
    :listing
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  view :edit_in_formula, tags: :unknown_ok do
    wrap do
      voo.live_options[:input_name] = "card[subcards][#{card.name}]"
      reset_form
      _render_editor
    end
  end

  view :editor do
    with_nest_mode :normal do
      output [render_hidden_content_field,
              variables_table,
              render_add_metric_button]
    end
  end

  def variables_table
    items = card.item_names context: :raw
    table items.map.with_index { |item, index| variable_row item, index },
          header: ["Metric", "Variable", "Example value"]
  end

  view :add_metric_button do
    wrap_with :span, class: "input-group" do
      button_tag class: "_add-metric-variable slotter",
                 situation: "outline-secondary",
                 data: { toggle: "modal", target: "#modal-add-metric-slot" },
                 href:  add_metric_path do
        fa_icon(:plus) + " add metric"
      end
    end
  end

  def add_metric_path
    path layout: :simple_modal,
         view: :filter_items,
         item: implicit_item_view,
         filter_card: filter_card.name,
         item_selector: "thumbnail",
         slot_selector: card.patterns.first.safe_key,
         slot: { hide: :modal_footer },
         filter: { not_ids: card.item_ids.map(&:to_s).join(",") }
  end

  def variable_row item_name, index
    item_card = Card[item_name]
    [nest(item_card, view: :thumbnail), "M#{index}", example_value(item_card).html_safe]
  end

  def example_value variable_card
    return "" unless (value = variable_card.try(:random_value_card))
    nest(value, view: :concise, hide: :year).html_safe # html_safe necessary?
  end

  view :missing do
    return super() unless card.new_card?
    if card.formula_card
      card.extract_metrics_from_formula
    else
      Auth.as_bot { card.save! }
    end
    render! @denied_view
  end

  view :new, :missing
end
