include_set Abstract::FilterHelper

def chartable_type?
  relationship? || numeric? || categorical?
end

format :html do
  view :chart, cache: :never do
    return unless show_chart?

    wrap do
      wrap_with :div, "", id: chart_id, class: chart_class, data: { url: chart_load_url }
    end
  end

  def chart_id
    unique_id.tr "+", "-"
  end

  def chart_class
    "#{classy 'vis'} _load-vis"
  end

  def chart_load_url
    path view: :vega, format: :json, filter: chart_filter_hash, limit: 0
  end

  # json does not show not-researched answers.
  def chart_filter_hash
    filter_hash.dup.tap do |hash|
      hash.delete(:status) if hash[:status]&.to_sym == :all
    end
  end

  def show_chart?
    voo.show?(:chart) && card.chartable_type? && chartable_filter?
  end

  def chartable_filter?
    !filter_hash[:status].in? %w[none unknown]
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never do
    # ve = JSON.pretty_generate vega_chart_config.to_hash
    # puts ve
    vega.render
  end

  view :compact_answers do
    chart_query.answer_lookup.map do |answer|
      answer.compact_json.merge id: answer.flex_id
    end
  end
end
