include_set Abstract::Chart

format :json do
  def vega_chart_config _highlight=nil
    @data ||= chart_class.new(
      self, highlight: card.value, axes: :light,
            layout: { height: 80, width: 200, max_ticks: 5, padding: 2 }
    )
  end

  def sort_hash
    { sort_by: :year }
  end

  def horizontal_ok?
    false
  end

  def chart_metric_id
    card.metric_card.id
  end

  def chart_filter_hash
    super.merge year: card.year.to_i
  end
end
