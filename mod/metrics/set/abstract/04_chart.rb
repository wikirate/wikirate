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

  delegate :chart_params to: :card
end

format do
  def chart_item_count
    @chart_item_count ||= chart_filter_query.count
  end

  def chart_value_count
    @chart_value_count ||= chart_filter_query.value_count
  end

  def chart_filter_query
    FixedMetricAnswerQuery.new chart_metric_id,
                               chart_filter_hash
  end

  def chart_metric_id
    card.id
  end

  def chart_filter_hash
    card.filter_hash(zoom_in?)
  end

  def zoom_in?
    card.numeric? # && chart_item_count > 10
  end
end

format :html do
  view :chart, cache: :never do
    vega_chart if show_chart?
  end

  def chartkick_chart
    line_chart path(view: :chartkick, format: :json)
  end

  def vega_chart
    id = unique_id.tr "+", "-"
    output [
      zoom_out_link,
      wrap_with(:div, "",
                id: id, class: "#{classy('vis')} _load-vis",
                data: { url: chart_load_url })
    ]
  end

  def chart_load_url
    path_opts = { view: :vega, format: :json,
                  filter: filter_hash(false),
                  chart: chart_params }
    path path_opts
  end

  def show_chart?
    return if card.relationship? || !(card.numeric? || card.categorical?)

    card.filter_hash[:metric_value] != "none" &&
      card.filter_hash[:metric_value] != "all" &&
      card.filter_hash[:metric_value] != "unknown" # &&
    # chart_item_count > 3
  end

  def zoom_out_link
    return unless zoomed_in?
    link_to_view :content, fa_icon(:zoom_out),
                 path: zoom_out_path_opts,
                 class: "slotter chart-zoom-out"
  end

  def zoom_out_path_opts
    { chart: chart_params[:zoom_out],
      filter: filter_hash(false) }
  end

  def zoomed_in?
    chart_params.present?
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never do
    # ve = JSON.pretty_generate vega_chart_config.to_hash
    # puts ve
    vega_chart_config(value_to_highlight).to_json
  end

  # alternative library to vega
  view :chartkick, cache: :never do
    Answer.where(metric_id: card.id, latest: true)
          .group("CAST(value AS decimal)").count.chart_json
  end

  def vega_chart_config highlight=nil
    @data ||= chart_class.new self, link: true, highlight: highlight
  end

  def chart_class
    if card.scored?
      Card::Chart::ScoreChart
    elsif card.numeric?
      Card::Chart::NumericChart
    else
      Card::Chart::CategoryChart
    end
  end
end
