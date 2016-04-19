

format :html do

  def metric_names
    Env.params['metric']
  end

  def metric_card metric_name
    Card.fetch(metric_name)
  end

  def wrap_metric metric_card
    wrap do
      nest(metric_card, view: :core, structure: 'metric short view')
    end
  end

  def wrap_metric_list
    wrap_with :div do
      [
        content_tag(:hr),
        content_tag(:h4, 'Metrics'),
        content_tag(:hr),
        (metric_names.map.with_index do |key|
          metric_company = [key, card.name].join('+')
          wrap_metric(Card.fetch(metric_company)) if Card.exists? key
        end.join "\n")
      ]
    end
  end

  def wrap_company
    wrap_with :div do
      [
        content_tag(:h4, 'Company'),
        content_tag(:hr),
        nest(card, view: :core, structure: 'metric value company view')
      ]
    end
  end

  view :new_metric_value do |args|
    frame args do
      output(
        [
          _render_metric_side,
          _render_source_side
        ])
    end
  end

  view :metric_side do
    html_classes = 'col-md-6 border-right panel-default nodblclick'
    wrap_with :div, class: html_classes do
      [
        wrap_company.html_safe,
        wrap_metric_list.html_safe,
      ]
    end
  end

  view :source_side do
    source_side = Card.fetch('source preview main')
    subformat(source_side).render_core
  end
end
