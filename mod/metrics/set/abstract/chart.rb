include_set Abstract::FilterHelper

format :html do
  view :chart do
    vega_chart if show_chart?
  end

  def chartkick_chart
    line_chart path(view: :chartkick, format: :json)
  end

  def vega_chart
    url = path view: :vega, format: :json, highlight: 13
    id = unique_id.tr "+", "-"
    wrap_with :div, "", id: id, class: classy("vis"), data: { url: url }
  end

  def show_chart?
    card.numeric? || card.categorical?
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never do
    # ve = JSON.pretty_generate vega_chart_config.to_hash
    vega_chart_config(params[:highlight]).to_json
  end

  view :chartkick do
    MetricAnswer.where(metric_id: card.id, latest: true)
      .group("CAST(value AS decimal)").count.chart_json
  end

  def vega_chart_config highlight=nil
    @data ||= chart_class.new(self, link: true, highlight: highlight)
  end

  def chart_class
    card.numeric? ? Card::Chart::NumericChart : Chart::CategoryChart
  end

  def chart_metric_id
    card.id
  end

  def chart_filter_query
    FixedMetricAnswerQuery.new chart_metric_id, card.filter_hash
  end
end


