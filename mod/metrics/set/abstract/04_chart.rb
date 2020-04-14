include_set Abstract::FilterHelper

def filter_hash with_select_filter=true
  filter = super()
  return filter unless with_select_filter && chart_params[:select_filter]
  filter.merge chart_params[:select_filter]
end

def chart_params
  @chart_params ||= Env.hash Env.params[:chart]
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
    AnswerQuery.new chart_filter_hash.merge(metric_id: chart_metric_id), card.sort_hash
  end

  def chart_metric_id
    card.id
  end

  def chart_filter_hash
    if card.chart_filter_params.present?
      card.chart_filter_params
    else
      default_chart_filter_hash
    end
  end

  # vega chart does not show not-researched answers.
  def default_chart_filter_hash
    hash = card.filter_hash(false).clone
    hash.delete(:status) if hash[:status]&.to_sym == :all
    hash
  end

  def zoom_in?
    card.numeric? # && chart_item_count > 10
  end
end

format :html do
  view :chart, cache: :never do
    return unless show_chart?

    wrap_with :div, "", id: chart_id, class: chart_class, data: { url: chart_load_url }
  end

  def chart_id
    unique_id.tr "+", "-"
  end

  def chart_class
    "#{classy('vis')} _load-vis"
  end

  def chart_load_url
    path view: :vega, format: :json, filter: filter_hash(false), chart: chart_params
  end

  def show_chart?
    voo.show?(:chart) && chartable_type? && chartable_filter?
  end

  def chartable_type?
    card.relationship? || card.numeric? || card.categorical?
  end

  def chartable_filter?
    !card.filter_hash[:status].in? %w[none unknown]
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never do
    # ve = JSON.pretty_generate vega_chart_config.to_hash
    # puts ve
    vega_chart_config(value_to_highlight).to_json
  end

  def vega_chart_config highlight=nil
    @data ||= chart_class.new self, highlight: highlight
  end

  def chart_class
    VegaChart.chart_class self, horizontal_ok?
  end

  def horizontal_ok?
    true
  end
end
