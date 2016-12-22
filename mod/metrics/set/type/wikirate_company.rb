include_set Abstract::WikirateTable # deprecated but maybe still used somewhere
include_set Abstract::Table

format :html do
  def metric_names
    return project.field(:metric).item_names if project
    Env.params["metric"] || []
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

  def wrap_record record_card
    wrap do
      wrap_with :div, id: record_card.cardname.url_key, class: "metric-row" do
        [
          subformat(record_card).process_content(metric_header_small),
          subformat(record_card).process_content(metric_details),
          nest(record_card.fetch(trait: :metric_value), view: :record_list_header),
          record_list(record_card)
        ]
      end
      #nest(record_card, view: :core, structure: "metric short view")
    end
  end

  def record_list record_card
    items = Answer.fetch({ record_id: record_card.id },
                         sort_by: :year,
                         sort_order: "desc")
    wikirate_table :plain, items,
                   [:plain_year, :closed_answer_without_chart],
                   header: %w(Year Answer),
                   td: { classes: ["text-center"] }
  end

  # FIXME
  def metric_header_small
    <<-HTML
        <div class="metric-details-header col-md-12 col-xs-12 padding-top-10">
  <div class="row">
    <div class="row-icon no-icon-bg padding-top-10">
      	<a class="pull-left editor-image inherit-anchor" href="{{_llr+_lr|url}}">
            {{_llr+image|size:small}}
        </a>
    </div>
    <div class="row-data">
      	<h4 class="metric-color">
  					<a class="inherit-anchor" href="{{_llr+_lr|url}}">{{_lr|name}}</a>
  			</h4>
    </div>
  </div>
</div>
    HTML
  end

  # FIXME
  def metric_details
    <<-HTML

<div class="metric-info">
  <div class="col-md-12 padding-bottom-10">
    <div class="row metric-details-question">
      <div class="row-icon padding-top-10">
        <i class="fa fa-question-circle fa-lg"></i>
      </div>
      <div class="row-data padding-top-10">
        {{_llr+_lr+question|core}}
      </div>
    </div>
  </div>

  <div class="col-md-12">
    <div id="methodology-info" class="collapse">
        <div class="row"><small><strong>Methodology </strong>{{_llr+_lr+Methodology|content;|link}}</small></div>
        <div class="row">
          <div class="row-icon">
            <i class="fa fa-tag"></i>
          </div>
          <div class="row-data">
            {{_llr+_lr+topics|content|link}}
          </div>
        </div>
    </div>
  </div>
</div>
    HTML
  end

  def wrap_project
    return unless project
    project_content =
      nest(project, view: :core, structure: "initiative item").html_safe
    wrap_with :div, class: "border-bottom col-md-12 nopadding" do
      [
        wrap_with(:h5, "Project :", class: "col-md-2"),
        wrap_with(:div, project_content, class: "col-md-10")
      ]
    end
  end

  def wrap_metric_header
    wrap_with(:div, "Metrics", class: "heading-label")
  end

  def wrap_metric_list
    wrap_with :div, class: "row background-grey" do
      [
        wrap_metric_header,
        wrap_project,
        process_metrics
      ]
    end
  end

  def not_a_metric name
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available: "\
                   "#{name}"
    card.format.render_errors
  end

  def existing_metric? name
    (m = Card.quick_fetch(name)) && m.type_id == MetricID
  end

  def process_metrics
    metric_names.map do |metric_name|
      next not_a_metric(metric_name) unless existing_metric? metric_name
      metric_plus_company = Card.fetch metric_name, card.name
      wrap_record metric_plus_company
    end.join "\n"
  end

  def wrap_company
    wrap_with :div, class: "row" do
      [
        wrap_with(:div, "Company", class: "heading-label"),
        nest(card, view: :core, structure: "metric value company view")
      ]
    end
  end

  view :new_metric_value, cache: :never do
    frame do
      output [_render_metric_side, _render_source_side]
    end
  end

  view :metric_side, cache: :never do
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
        wrap_with(:div, subformat(source_side).render_core.html_safe,
                    id: "source-form-container")
      end
    wrap do
      blank_content.html_safe
    end
  end

  view :company_row_for_topic do |args|
    company_row_for_topic args
  end
end
