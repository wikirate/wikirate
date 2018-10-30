include_set Abstract::MetricChild, generation: 1
include_set Type::Pointer
include_set Abstract::Variable
include_set Abstract::Table

# The Metric+:metric_variables help support +:formula cards. They're used:
#   A. by Formula metrics as a holder (and name shortener) for
#      variable metrics that may or may not already be in the formula, and
#   B. by WikiRating metrics as a hidden container that helps with state
#      maintenance
#
# In both cases, the +:metric_variables card is the integration point for
# the filtered list interface

# +:metric_variables cards are never stored.
event :abort_storage, :validate, on: :save do
  abort :success
end

def formula_card
  metric_card.fetch trait: :formula
end

# db_content should only be present when it has been set by a `card[content]` parameter.
def content
  @content ||=
    db_content.present? ? db_content : variables_in_use.to_pointer_content
end

# existing variables from the +:formula card
def variables_in_use
  formula_card&.input_names || []
end

format :html do
  def default_item_view
    :mini_bar
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  def variable_editor
    wrap { with_nest_mode(:normal) { yield } }
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

  # TODO: make sure card.metric_card.id remains in not_id filters
  # currently it only limits the initial filter.
  def not_ids
    card.item_ids.push(card.metric_card.id).compact.map(&:to_s).join(",")
  end

  def initial_filters added_filters
    { not_ids: not_ids }.merge added_filters
  end
end
