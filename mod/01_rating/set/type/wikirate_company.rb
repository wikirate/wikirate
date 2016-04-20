

format :html do

  def metric_names
    if project
      project.field('metric').item_names
    else
      Env.params['metric']
    end
  end

  def project
    Card.fetch(Env.params['project']) || false
  end

  def wrap_metric metric_card
    wrap do
      nest(metric_card, view: :core, structure: 'metric short view')
    end
  end

  def wrap_project
    project_content =
      nest(project, view: :core, structure: 'initiative item').html_safe
    wrap_with :div, class: 'border-bottom col-md-12 nopadding' do
      [
        content_tag(:h5, 'Project :', class: 'col-md-2'),
        content_tag(:div, project_content, class: 'col-md-10')
      ]
    end
  end

  def wrap_metric_header
    metric_list_header = content_tag(:div, 'Metrics', class: 'heading-label')
    if project
      metric_list_header << wrap_project
    else
      metric_list_header
    end
  end

  def wrap_metric_list
    wrap_with :div, class: 'row' do
      [
        wrap_metric_header,
        (metric_names.map.with_index do |key|
          metric_company = Card.fetch(key).field(card.name)
          wrap_metric(metric_company) if Card.exists? key
        end.join "\n")
      ]
    end
  end

  def wrap_company
    wrap_with :div, class: 'row' do
      [
        content_tag(:div, 'Company', class: 'heading-label'),
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
        wrap_metric_list.html_safe
      ]
    end
  end

  view :source_side do
    source_side = Card.fetch('source preview main')
    wrap do
      subformat(source_side).render_core
    end
  end
end
