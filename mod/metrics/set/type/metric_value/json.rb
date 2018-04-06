include_set Abstract::Chart

format :json do
  def vega_chart_config _highlight=nil
    @data ||= chart_class.new(self,
                              highlight: card.value,
                              layout: { height: 70, width: 300,
                                        padding: { top: 10, left: 50,
                                                   bottom: 20, right: 30 },
                                        max_ticks: 5 },
                              link: false,
                              axes: :light)
  end

  def chart_metric_id
    card.metric_card.id
  end

  def chart_filter_hash
    super.merge year: card.year.to_i
  end

  view :core do
    data = _render_essentials.merge(
      metric: nest(card.metric, view: :essentials),
      company: nest(card.company, view: :marks)
    )
    data[:source] = nest(card.source, view: :essentials) if card.source.present?
    data.merge(checked_by: nest(card.checked_by_card, view: :essentials, hide: :marks))
  end

  def essentials
    {
      year: card.year.to_s,
      value: card.value,
      import: card.imported?,
      comments: field_nest(:discussion, view: :core)
    }
  end
end
