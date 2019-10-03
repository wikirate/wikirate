format :html do
  def input_type
    :constraint_list
  end

  def constraint_list_input
    constraints = card.constraints
    constraints = [nil] if constraints.empty?
    haml :constraint_list_input, constraints: constraints
  end

  view :core, template: :haml

  view :value_formgroup, cache: :never, unknown: true do
    value_formgroup Card[params[:metric]]
  end

  def value_formgroup metric, value=nil
    wrap do
      if metric&.type_id == Card::MetricID
        @metric_card = metric
        filter_value_formgroup metric.value_type_code, value
      else
        ""
      end
    end
  end

  def year_dropdown constraint
    selected = constraint&.year || "latest"
    select_filter :year, selected
  end

  # TODO: merge with #autocomplete_field on research page
  def metric_dropdown constraint
    selected = constraint&.metric&.name || ""
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
