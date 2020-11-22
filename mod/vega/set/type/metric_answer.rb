include_set Abstract::Chart

format :json do
  def vega
    VegaChart::SingleMetric.new self, chart_metric,
                                highlight: card.value,
                                axes: :light,
                                layout: { height: 80,
                                          width: 200,
                                          max_ticks: 5,
                                          padding: 2 }
  end

  def chart_metric
    card.metric_card
  end

  def sort_hash
    { sort_by: :year }
  end

  def chart_query
    AnswerQuery.new metric_id: card.metric_id, year: card.year
  end
end
