include_set Abstract::FilterHelper

def filter_hash with_chart_filter=true
  filter = super()
  with_chart_filter ? filter.merge(chart_filter_params) : filter
end

def chart_params
  Env.params[:chart].is_a?(Hash) ? Env.params[:chart] : {}
end

def chart_filter_params
  chart_params[:filter] || {}
end

format do
  def value_to_highlight
    return unless chart_params[:highlight].present?
    chart_params[:highlight]
  end

  delegate :chart_params, :filter_hash, to: :card
end

format :html do
  view :chart do
    vega_chart if show_chart?
  end

  def chartkick_chart
    line_chart path(view: :chartkick, format: :json)
  end

  def vega_chart
    id = unique_id.tr "+", "-"
    wrap_with :div, "", id: id, class: classy("vis"),
              data: { url: chart_load_url }
  end

  def chart_load_url
    path_opts = { view: :vega, format: :json,
                  filter: filter_hash(false),
                  chart: chart_params }
    path path_opts
  end

  def show_chart?
    card.numeric? || card.categorical?
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never do
    # ve = JSON.pretty_generate vega_chart_config.to_hash
    vega_chart_config(value_to_highlight).to_json
  end

  view :chartkick do
    MetricAnswer.where(metric_id: card.id, latest: true)
      .group("CAST(value AS decimal)").count.chart_json
  end

  def vega_chart_config highlight=nil
    @data ||= chart_class.new(self, link: true, highlight: highlight)
  end

  def chart_class
    card.numeric? ? Card::Chart::NumericChart : Card::Chart::CategoryChart
  end

  def chart_metric_id
    card.id
  end

  def chart_filter_query
    FixedMetricAnswerQuery.new chart_metric_id, card.filter_hash(false)
  end
end
