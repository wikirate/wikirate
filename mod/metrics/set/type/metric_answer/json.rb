include_set Abstract::Chart

format :json do
  def vega_chart_config _highlight=nil
    @data ||= chart_class.new(
      self, highlight: card.value, axes: :light,
            layout: { height: 80, width: 200, max_ticks: 5, padding: 2 }
    )
  end

  def horizontal_ok?
    false
  end

  def chart_metric_id
    card.metric_card.id
  end

  def chart_filter_hash
    super.merge year: card.year.to_i
  end

  def atom
    atom = super
    %i[metric company year].each do |key|
      atom[key] = card.send key
    end
    atom[:value] = card.value # nest card.value_card, view: :core
    atom[:record_url] = path mark: card.name.left, format: :json
    atom.delete(:content)
    atom
  end

  def molecule
    super().merge sources: field_nest(:source, view: :items),
                  checked_by: field_nest(:checked_by)
  end

  def item_cards
    card.metric_card.relationship? ? companies : []
  end
end
