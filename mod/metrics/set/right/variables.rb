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

def extract_metrics_from_formula
  metrics = formula_card.input_names
  Auth.as_bot do
    update_attributes! content: metrics.to_pointer_content,
                       type_id: PointerID
  end
  metrics
end

def input_metric_name variable
  index = if variable.is_a?(Integer)
            variable
          elsif variable_name? variable
            variable_index variable
          end
  input_metric_name_by_index index if index
end

def input_metric_name_by_index index
  item_cards.fetch(index, nil).name
end

format :html do
  view :core do
    output [table(items.map.with_index { |item, index| variable_row item, index },
                  header: ["Metric", "Variable", "Example value"]),
            render_add_metric_button]
  end

  def items
    items =  card.item_names context: :raw
    return items if items.present?
    card.extract_metrics_from_formula
  end

  view :add_metric_button do
    target = "#modal-add-metric-slot"
    wrap_with :span, class: "input-group" do
      button_tag class: "pointer-item-add slotter", situation: "outline-secondary",
                 data: { toggle: "modal", target: target },
                 href: path(layout: "modal", view: :edit, mark: card.name,
                            slot: { title: "Choose Metric" }) do
        fa_icon(:plus) + " add metric"
      end
    end
  end

  def variable_row item_name, index
    item_card = Card[item_name]
    example_value =
      if (value = item_card.try(:random_value_card))
        nest value, view: :concise, hide: :year
      else
        ""
      end
    [
      subformat(item_card)._render_thumbnail,
      "M#{index}", # ("A".ord + args[:index]).chr
      example_value.html_safe
    ]
  end

  view :edit do |_args|
    return super() unless card.metric_card
    voo.hide! :toolbar, :menu
    frame do
      nest [card.metric_card_name, :add_to_formula], view: :select_modal
    end
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
