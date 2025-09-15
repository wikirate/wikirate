include_set Abstract::Chart

format :json do
  delegate :metric_card, to: :card

  def vega
    VegaChart.new metric_card.chart_class, self,
                  highlight: card.value,
                  axes: :light,
                  layout: { height: 80, width: 200, max_ticks: 5, padding: 2 }
  end

  # simulate filtering to keep charts from breaking
  def filter_hash
    {}
  end

  view :answer_list, cache: :never, perms: :none do
    chart_query.lookup_relation.map(&:compact_json)
  end

  def chart_query
    AnswerQuery.new metric_id: card.metric_id, year: card.year
  end
end
