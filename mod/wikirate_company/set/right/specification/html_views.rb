format :html do
  view :core, template: :haml

  view :value_formgroup, cache: :never, unknown: true do
    value_formgroup Card[params[:metric]]
  end

  def help_text
    "Specify which companies are in the group implicitly or explicitly."
  end

  def input_type
    :specification
  end

  def specification_input
    haml :specification_input
  end

  def constraint_list_input
    constraints = card.constraints
    constraints = [nil] if constraints.empty?
    haml :constraint_list_input, constraints: constraints
  end

  def pretty_constraint value
    case value
    when String
      value
    when Array
      value.join ", "
    when Hash
      pretty_hash_constraint value
    end
  end

  def pretty_hash_constraint hash
    hash = hash.symbolize_keys
    array = []
    array << ">#{hash[:from]}" if hash[:from].present?
    array << "<#{hash[:to]}" if hash[:to].present?
    pretty_constraint array
  end

  def value_formgroup metric, value=nil
    wrap do
      if metric&.type_id == Card::MetricID
        @metric_card = metric
        filter_value_formgroup metric.simple_value_type_code, value
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
