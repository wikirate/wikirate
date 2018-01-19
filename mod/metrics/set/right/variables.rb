include_set Type::Pointer
include_set Abstract::Variable
include_set Abstract::Table

# FIXME: following does not prevent storage.
# event :abort_storage, :validate, on: :save do
#   abort :success
# end

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
  @content ||=
    db_content.present? ? db_content : variables_in_use.to_pointer_content
  # db_content should only be present when it has been set by a `card[content]`
  # parameter. the variable card is not intended to be saved.
end

def variables_in_use
  formula_card&.input_names || []
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
    with_hidden_subcard_content_slot { _render_editor }
  end

  def with_hidden_subcard_content_slot
    wrap do
      subcard_voo
      with_nest_mode :normal do
        output [render_hidden_content_field, yield]
      end
    end
  end

  def subcard_voo
    voo.live_options[:input_name] = "card[subcards][#{card.name}]"
    reset_form
  end

  view :edit_in_wikirating, tags: :unknown_ok do
    with_hidden_subcard_content_slot { _render_weight_variable_editor }
  end

  view :weight_variable_editor, tags: :unknown_ok  do
    filters = %i[score wiki_rating].map { |code| Card::Name[code] }
    button = add_metric_button "_add-wikirating-variable",
                               metric_type: filters
    output [weight_variable_list, button]
  end

  def weight_variable_list
    table_content = card.item_cards.map do |metric|
      nest metric, view: :weight_row
    end
    table table_content, class: "weight-variable-list hidden"
  end

  view :editor do
    output [variables_table,
            add_metric_button("_add-formula-variable")]
  end

  def variables_table
    items = card.item_names context: :raw
    table items.map.with_index { |item, index| variable_row item, index },
          header: ["Metric", "Variable", "Example value"]
  end

  def add_formula_metric_button
    add_metric_button "add-formula-metric"
  end

  def add_metric_button klass, filters={}
    wrap_with :span, class: "input-group" do
      button_tag class: "_add-metric-variable slotter #{klass}",
                 situation: "outline-secondary",
                 data: { toggle: "modal", target: "#modal-add-metric-slot" },
                 href: add_metric_path(filters) do
        fa_icon(:plus) + " add metric"
      end
    end
  end

  def add_metric_path filters
    path layout: :simple_modal,
         view: :filter_items,
         item: implicit_item_view,
         filter_card: filter_card.name,
         item_selector: "thumbnail",
         slot_selector: "#{card.patterns.first.safe_key}.edit_in_formula-view",
         slot: { hide: :modal_footer },
         filter: initial_filters(filters)
  end

  def initial_filters added_filters
    { not_ids: card.item_ids.map(&:to_s).join(",") }.merge added_filters
  end

  def variable_row item_name, index
    item_card = Card[item_name]
    [nest(item_card, view: :thumbnail), "M#{index}", example_value(item_card).html_safe]
  end

  def example_value variable_card
    return "" unless (value = variable_card.try(:random_value_card))
    nest(value, view: :concise, hide: :year).html_safe # html_safe necessary?
  end
end
