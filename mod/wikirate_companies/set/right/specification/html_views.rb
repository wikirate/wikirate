format :html do
  delegate :metric_card, to: :card

  view :core, template: :haml

  view :value_formgroup, cache: :never, unknown: true do
    value_formgroup params[:metric]&.card
  end

  view :metric_selector, unknown: true do
    wrap_with :div, class: "_specification-metric-selector" do
      nest :metric, view: :filtered_content
    end
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
    constraints = card.content_from_params || card.constraints
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

  def year_dropdown year, disabled
    select_filter_tag :year, (year || "latest"), filter_year_options, disabled: disabled
  end

  def filter_year_options
    { "Any" => "any" }.merge super
  end

  def metric_selector metric
    haml :metric_selector, metric: metric
  end

  def filter_prefix
    "filter[company_answer][]"
  end
end
