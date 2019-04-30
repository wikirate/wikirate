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
