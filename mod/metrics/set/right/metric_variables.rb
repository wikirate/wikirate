include_set Abstract::MetricChild, generation: 1
include_set Type::Pointer
include_set Abstract::Variable
include_set Abstract::Table

# The Metric+:metric_variables card are used:
#   A. by Formula metrics as a holder (and name shortener) for
#      variable metrics that may or may not already be in the formula, and
#   B. by WikiRating metrics as a hidden container that helps with state
#      maintenance and integration of the filtered list interface

# these cards are never stored.
event :abort_storage, :validate, on: :save do
  abort :success
end

def formula_card
  metric_card.fetch trait: :formula
end

# the conten
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

  view :edit_in_formula, tags: :unknown_ok, cache: :never do
    @explicit_form_prefix = "card[subcards][#{card.name}]"
    reset_form
    output [render_hidden_content_field, variable_editor { _render_editor }]
  end

  def variable_editor
    wrap { with_nest_mode(:normal) { yield } }
  end

  view :edit_in_wikirating, tags: :unknown_ok do
    variable_editor { output [weight_variable_list, add_wikirate_variable_button] }
  end

  def weight_variable_list
    wrap_with :div, class: "weight-variable-list hidden" do
      card.item_cards.map do |metric|
        nest metric, view: :thumbnail_no_link
      end
    end
  end

  view :editor do
    output [variables_table, add_formula_variable_button]
  end

  def variables_table
    items = card.item_names context: :raw
    table items.map.with_index { |item, index| variable_row item, index },
          header: ["Metric", "Variable", "Example value"]
  end

  def add_formula_variable_button
    add_variable_button "_add-formula-variable", slot_selector(:edit_in_formula)
  end

  def add_wikirate_variable_button
    add_variable_button "_add-wikirating-variable", slot_selector(:edit_in_wikirating),
                        metric_type: %i[score wiki_rating].map { |mt| Card::Name[mt] }
  end

  def slot_selector view
    "#{card.patterns.first.safe_key}.#{view}-view"
  end

  def add_variable_button klass, slot_selector, filters={}
    wrap_with :span, class: "input-group" do
      button_tag class: "_add-metric-variable slotter #{klass}",
                 situation: "outline-secondary",
                 data: { toggle: "modal", target: "#modal-add-metric-slot" },
                 href: add_variable_path(slot_selector, filters) do
        fa_icon(:plus) + " add metric"
      end
    end
  end

  def add_variable_path slot_selector, filters
    path layout: :simple_modal,
         view: :filter_items,
         item: implicit_item_view,
         filter_card: filter_card.name,
         item_selector: "thumbnail",
         slot_selector: slot_selector,
         slot: { hide: :modal_footer },
         filter: initial_filters(filters)
  end

  def initial_filters added_filters
    { not_ids:   card.item_ids.map(&:to_s).join(",") }.merge added_filters
  end

  def variable_row item_name, index
    item_card = Card[item_name]
    [nest(item_card, view: :thumbnail), "M#{index}", example_value(item_card).html_safe]
  end

  def example_value variable_card
    return "" unless (value = variable_card.try(:random_value_card))
    nest(value, view: :concise, hide: :year_equals).html_safe # html_safe necessary?
  end
end
