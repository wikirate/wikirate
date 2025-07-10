format :html do
  view :chart, cache: :never do
    return unless voo.show? :chart

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
    path view: :vega,
         format: :json,
         filter: chart_filter_hash,
         limit: 0,
         chart: params[:chart],
         subgroup: params[:subgroup]
  end

  # json does not show not-researched answers.
  def chart_filter_hash
    filter_hash.dup.tap do |hash|
      hash.delete(:status) if hash[:status]&.to_sym == :all
    end
  end
end

format :json do
  # views requested by ajax to load chart
  view :vega, cache: :never, perms: :none do
    vega.render
  end

  def vega_path view
    path view: view, format: :json, limit: 0, filter: filter_hash
  end
end
