include_set Abstract::Chart

format :json do
  def item_cards
    %i[ source checked_by].map do |key|
      card.send "#{key}_card"
    end.select &:known?
  end

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

  view :atom do
    atom = super()
    %i[metric company year].each do |key|
      atom[key] = card.send key
    end
    atom[:value] = card.value
    atom.delete(:content)
    atom
  end

  view :core do
    essentials_for %i[metric company source checked_by relationships], _render_essentials
  end

  def essentials
    { year: card.year.to_s,
      value: card.value,
      import: card.imported?,
      comments: field_nest(:discussion, view: :core) }
  end

  def essentials_for symbols, hash
    symbols.each do |field|
      value = send "essentials_for_#{field}"
      hash[field] = value if value
    end
    hash
  end

  def essentials_for_metric
    nest card.metric, view: :essentials
  end

  def essentials_for_company
    nest card.company, view: :marks
  end

  def essentials_for_source
    return unless card.source.present?
    nest card.source, view: :essentials
  end

  def essentials_for_checked_by
    nest card.checked_by_card, view: :essentials, hide: :marks
  end

  def essentials_for_relationships
    return unless card.metric_card.relationship?
    companies.map do |relationship|
      nest relationship, view: :from_answer
    end
  end
end
