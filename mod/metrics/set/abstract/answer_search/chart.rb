HORIZONTAL_MAX = 10

format do
  def single_year?
    filter_hash[:year].present?
  end

  def single_metric?
    filter_hash[:metric_id].is_a? Integer
  end

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
    elsif single_metric?
      single_metric_chart_type
    elsif single_year?
      single_year_chart_type
    else
      :timeline
    end
  end

  def single_year_chart_type
    metric_count > 75 || company_count > 75 ? :pie : :grid
  end

  def single_metric_chart_type
    metric_card.chart_class horizontal?
  end

  def horizontal?
    count_by_status[:known] <= HORIZONTAL_MAX
  end

  def grid_options
    (40 - metric_count).abs > (40 - company_count).abs ? { invert: true } : {}
  end
end
