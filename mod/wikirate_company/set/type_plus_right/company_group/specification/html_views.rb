format :html do
  def input_type
    :constraint_list
  end

  def constraint_list_input
    haml :constraint_list_input
  end

  view :core, template: :haml

  view :value_formgroup, cache: :never, unknown: true do
    value_formgroup Card[params[:metric]]
  end

  def value_formgroup metric_card, value=nil
    wrap do
      if metric_card
        @metric_card = metric_card
        filter_value_formgroup metric_card.value_type_code, value
      else
        ""
      end
    end
  end

  # TODO: merge with #autocomplete_field on research page
  def metric_dropdown selected=nil
    text_field_tag "constraint_metric", selected,
                   class: "_constraint-metric metric_autocomplete " \
                          "pointer-item-text form-control",
                   "data-options-card": Card::Name[:metric, :type, :by_name],
                   placeholder: "Enter Metric"
  end

  # this override prevents the addition of a bunch of unnecessary filter-related classes,
  # etc.
  def normalize_select_filter_tag_html_options _field, _html_options
    # NOOP
  end
end
