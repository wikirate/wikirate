# How the views for adding answers currently work:
# The starting point is Type::Company#new_metric_value.
# The "Add answer" button fetches the form from Type::MetricValue#new using
# params for metric and company and the additional param table_form is
# set to true to get the right new view.
# The table and the form are merged in
# script_metric_value.js.coffee#wikirate.appendNewValueForm.
# If the form is needed on load an "_append_new_value_form" class is added
# to the slot to trigger the ajax request for the form and merge it with
# the table.
# The table with the existing values is just the content view of a
# metric record. Since there is no MetricRecord type it's handled in
# LtypeRtype::Metric::WikirateCompany

include_set Abstract::Table

format :html do
  view :new_metric_value, cache: :never do
    frame do
      haml_view :new_metric_value_form
    end
  end

  def process_metrics
    metric_names.map do |metric_name|
      next not_a_metric(metric_name) unless existing_metric? metric_name
      wrap_record metric_name
    end.join "\n"
  end

  def wrap_record metric_name
    record_card = Card.fetch metric_name, card.name, new: {}
    wrap do
      wrap_with :div, id: record_card.cardname.url_key, class: "metric-row" do
        [
          subformat(record_card).process_content(metric_header_small),
          nest(record_card, view: :content, hide: :chart, show:
            [:metric_info])
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

  def view_template_path view
    super(view, __FILE__)
  end
end
