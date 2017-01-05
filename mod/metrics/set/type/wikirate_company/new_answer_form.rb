format :html do
  view :new_metric_value, cache: :never do
    frame do
      haml_view :new_metric_value_form
    end
  end
end

include_set Abstract::Table

format :html do
  def process_metrics
    metric_names.map do |metric_name|
      next not_a_metric(metric_name) unless existing_metric? metric_name
      wrap_record metric_name
    end.join "\n"
  end

  def wrap_record metric_name
    record_card = Card.fetch metric_name, card.name
    wrap do
      wrap_with :div, id: record_card.cardname.url_key, class: "metric-row" do
        [
          subformat(record_card).process_content(metric_header_small),
          subformat(record_card).process_content(metric_details),
          nest(record_card.fetch(trait: :metric_value),
               view: :record_list_header),
          _render_record_list(record: record_card)
        ]
      end
    end
  end

  view :record_list_header do
    voo.show :timeline_header_buttons
    wrap_with :div, class: "timeline-header timeline-row " do
      _optional_render_timeline_header_buttons
    end
  end

  def timeline_header_button text, klasses, data
    shared_data = { collapse: ".metric_value_form_container" }
    shared_classes = "btn btn-sm btn-default margin-12"
    wrap_with :a, text, class: css_classes(shared_classes, klasses),
              data: shared_data.merge(data)
  end

  view :timeline_header_buttons do
    return unless metric_card.metric_type_codename == :researched
    output [add_answer_button, methodology_button]
  end

  view :record_list, cache: :never do |args|
    record_card = args[:record]
    items = Answer.fetch({ record_id: record_card.id },
                         sort_by: :year,
                         sort_order: "desc")
    class_up "card_slot", "_append_new_value_form" if items.empty?
    wrap do
      wikirate_table :plain, items,
                     [:plain_year, :closed_answer_without_chart],
                     header: %w(Year Answer),
                     td: { classes: ["text-center"] }
    end
  end

  def project?
    project_name.present?
  end

  def project_name
    Env.params["project"]
  end

  def project
    return unless project?
    unless Card.exists? project_name
      card.errors.add :Project, "Project does not exist"
      return false
    end
    Card.fetch(project_name)
  end

  def metric_names
    return project.field(:metric).item_names if project
    Env.params["metric"] || []
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

  def view_path view
    ::File.expand_path("../#{view}.haml", __FILE__)
      .gsub(%r{/tmp/set/mod\d+-([^/]+)/}, '/mod/\1/view/')
  end

  def haml_wrap slot=true
    @slot_view = @current_view
    debug_slot do
      haml_tag :div, id: card.cardname.url_key,
               class: wrap_classes(slot),
               data: wrap_data do
        yield
      end
    end
  end

  def haml_view view, locals={}
    render_haml locals, ::File.read(view_path(view))
  end
end
