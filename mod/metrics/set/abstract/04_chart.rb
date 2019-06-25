include_set Abstract::FilterHelper

def filter_hash with_select_filter=true
  filter = super()
  return filter unless with_select_filter && chart_params[:select_filter]
  filter.merge chart_params[:select_filter]
end

def chart_params
  case (chart = Env.params[:chart])
  when Hash then chart
  when ActionController::Parameters then chart.to_unsafe_h
  else {}
  end
end

def chart_filter_params
  chart_params[:filter] || {}
end

format do
  def value_to_highlight
    return unless chart_params[:highlight].present?
    chart_params[:highlight]
  end

  delegate :chart_params, to: :card
end

format do
  def chart_item_count
    @chart_item_count ||= chart_filter_query.count
  end

  def chart_value_count
    @chart_value_count ||= chart_filter_query.main_query.distinct.count(:value)
  end

  def chart_filter_query
    AnswerQuery.new chart_filter_hash.merge(metric_id: chart_metric_id)
  end

  def chart_metric_id
    card.id
  end

  def chart_filter_hash
    card.chart_filter_params.present? ? card.chart_filter_params : card.filter_hash(false)
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
    path view: :vega, format: :json, filter: filter_hash(false), chart: chart_params
  end

  def show_chart?
    return unless card.relationship? || card.numeric? || card.categorical?

    !card.filter_hash[:status].in? %w[none unknown]
  end

  def zoom_out_link
    return unless zoomed_in?
    link_to_view :filter_result, fa_icon(:zoom_out),
                 path: zoom_out_path_opts, class: "chart-zoom-out"
  end

  def zoom_out_path_opts
    chart_params[:zoom_out]
  end

  def zoomed_in?
    chart_params.present? && chart_params[:zoom_level].to_i.positive?
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
    Vega.chart_class self
  end
end
