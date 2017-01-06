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
          nest(record_card, view: :content, hide: :chart, show: :metric_info)
        ]
      end
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
