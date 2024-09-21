HORIZONTAL_MAX = 10

format do
  def metric_card
    Card[filter_hash[:metric_id]]
  end
end

format :json do
  def vega
    type = chart_type
    options = default_vega_options.merge(try("#{type}_options") || {})
    VegaChart.new chart_type, self, options
  end

  def default_vega_options
    {}
  end

  def chart_type
    if (type = params[:chart])&.present?
      type.to_sym
    elsif single_metric_chart?
      single_metric_chart_type
    elsif single_year_chart?
      single_year_chart_type
    else
      :timeline
    end
  end

  def metric_count
    counts[:metric]
  end

  def company_count
    counts[:company]
  end

  def max_grid_cells
    75
  end

  def show_grid?
    metric_count <= max_grid_cells && company_count <= max_grid_cells
  end

  def single_metric_chart?
    filter_hash[:metric_id].is_a?(Integer) && counts[:known] > 1
  end

  def single_year_chart?
    single?(:year) || Array.wrap(filter_hash[:year]).first&.to_sym == :latest
  end

  def single_year_chart_type
    show_grid? ? :grid : :pie
  end

  def single_metric_chart_type
    metric_card.chart_class horizontal?
  end

  def horizontal?
    counts[:known] <= HORIZONTAL_MAX
  end

  def company_columns?
    optimal = max_grid_cells / 2
    (optimal - metric_count).abs > (optimal - company_count).abs
  end

  # determine which of metric/company is column/row
  def grid_options
    company_columns? ? { invert: true } : {}
  end

  def timeline_options
    chart_grouping
  end

  def pie_options
    chart_grouping
  end

  def chart_grouping
    group = params[:subgroup].to_sym if params[:subgroup].present?
    group ||= first_interesting_group %i[route value_type metric_type], :verification
    { group: group }
  end

  def first_interesting_group groups, fallback
    groups.find { |g| deep_counts[g].to_i > 1 && params[g].blank? } || fallback
  end
end
