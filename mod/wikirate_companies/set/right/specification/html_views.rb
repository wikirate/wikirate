format :html do
  delegate :metric_card, to: :card

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

  def pretty_value_constraint value
    case value
    when String
      value
    when Array
      value.join ", "
    when Hash
      pretty_hash_value_constraint value
    end
  end

  def pretty_hash_value_constraint hash
    hash = hash.symbolize_keys
    array = []
    array << ">#{hash[:from]}" if hash[:from].present?
    array << "<#{hash[:to]}" if hash[:to].present?
    pretty_value_constraint array
  end

  def value_formgroup metric, value=nil, group=nil
    wrap do
      if metric&.type_id == MetricID
        card.metric_card = metric
        haml :value_formgroup, metric: metric, value: value, group: group
      else
        ""
      end
    end
  end

  def year_dropdown constraint
    selected = constraint&.year || "latest"
    select_filter :year, selected, filter_year_options
  end

  def filter_year_options
    { "Any" => "any" }.merge super
  end

  # TODO: merge with #autocomplete_field on research page
  def metric_dropdown constraint
    selected = constraint&.metric&.name || params[:metric_name_delete_me] || ""
    text_field_tag "constraint_metric", selected,
                   class: "_constraint-metric metric_autocomplete " \
                          "pointer-item-text form-control",
                   "data-options-card": Card::Name[:metric, :type, :by_name],
                   placeholder: "Enter Metric"
  end

  def filter_prefix
    "filter[answer][]"
  end
end
