

format :html do
  def metric_names
    return project.field(:metric).item_names if project
    Env.params["metric"]
  end

  def project
    project_name = Env.params["project"]
    return false unless project_name
    if Card.exists? project_name
      Card.fetch(project_name)
    else
      card.errors.add :Project, "Project not exist"
      return false
    end
  end

  def wrap_metric metric_card
    wrap do
      nest(metric_card, view: :core, structure: "metric short view")
    end
  end

  def wrap_project
    project_content =
      nest(project, view: :core, structure: "initiative item").html_safe
    wrap_with :div, class: "border-bottom col-md-12 nopadding" do
      [
        content_tag(:h5, "Project :", class: "col-md-2"),
        content_tag(:div, project_content, class: "col-md-10")
      ]
    end
  end

  def wrap_metric_header
    metric_list_header = content_tag(:div, "Metrics", class: "heading-label")
    if project
      metric_list_header << wrap_project
    else
      metric_list_header
    end
  end

  def error
    process_metrics
  rescue
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available."
    return false
  end

  def process_metrics
    metric_names.map do |metric_name|
      next unless Card.exists? metric_name
      metric_plus_company = Card.fetch metric_name, card.name
      wrap_metric metric_plus_company
    end.join "\n"
  end

  def wrap_metric_list
    return card.format.render_errors unless error
    wrap_with :div, class: "row background-grey" do
      [
        wrap_metric_header,
        process_metrics
      ]
    end
  end

  def wrap_company
    wrap_with :div, class: "row" do
      [
        content_tag(:div, "Company", class: "heading-label"),
        nest(card, view: :core, structure: "metric value company view")
      ]
    end
  end

  view :new_metric_value do
    frame do
      output [_render_metric_side, _render_source_side]
    end
  end

  view :metric_side do
    # html_classes = "col-md-6 col-lg-5 panel-default nodblclick stick-left"
    html_classes = "panel-default nodblclick stick-left"
    wrap_with :div, class: html_classes, id: "metric-container" do
      [
        wrap_company.html_safe,
        wrap_metric_list.html_safe
      ]
    end
  end

  view :source_side do
    source_side = Card.fetch("source preview main")
    # html_classes = "col-md-6 col-lg-7 panel-default stick-right"
    html_classes = "panel-default stick-right"

    blank_content =
      wrap_with :div, class: html_classes, id: "source-preview-main" do
        content_tag(:div, subformat(source_side).render_core.html_safe,
                    id: "source-form-container")
      end
    wrap do
      blank_content.html_safe
    end
  end

  view :topic_company_row do
    topic = parent.card.cardname.left
    wrap do
      process_content <<-HTML
      <div class="yinyang-row">
        <div class="company-item contribution-item">
          <div class="header">
            <div class="logo">
              {{_+image|core;size:small}}
            </div>
            <a class="name" href="{{_|linkname}}">{{_|name}}</a>
          </div>
          <div class="data">
            {{_1+#{topic}+analysis contributions|core}}
          </div>
          <div class="details"></div>
        </div>
      </div>
      HTML
    end
  end
end
