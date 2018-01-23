include_set Abstract::Media
card_accessor :metric
card_accessor :wikirate_company

format :html do
  view :new do
    voo.hide :menu
    with_nest_mode :edit do
      frame do
        [_render_landing_form, haml(:source_container)]
      end
    end
  end

  view :open do
    voo.hide :menu
    super()
  end

  view :content do
    _render_core
  end

  view :core, cache: :never do
    render_slot_machine
    # return _render_new unless companies && metrics
    # wrap do
    #   haml :research_form
    # end
  end

  view :source_side, template: :haml

  view :landing_form, cache: :never do
    field_content_from_params
    html_class = "col-md-5 border-right panel-default min-page-height"
    wrap_with :div, class: html_class do
      card_form :update, success: { view: :open } do
        [
          hidden_source_field,
          company_field, hr,
          metric_field,
          next_button
        ]
      end
    end
  end

  def field_content_from_params
    if params[:metric] || project
      card.metric_card.update_attributes! content: metrics.to_pointer_content
    end
    if params[:company]
      card.company_card.content.update_attributes! content: params[:company]
    end
  end

  def process_metrics
    metrics.map do |metric_name|
      next not_a_metric(metric_name) unless existing_metric? metric_name
      record_card = Card.fetch metric_name, companies.first, new: {}
      nest record_card, view: :core, hide: [:chart, :add_answer_redirect]
    end.join
  end

  def project?
    project.present?
  end

  def project
    @selected_project ||= Env.params["project"]
  end

  def project_card
    return unless project?
    unless Card.exists? project
      card.errors.add :Project, "Project does not exist"
      return nil
    end
    Card.fetch(project)
  end

  def not_a_metric name
    card.errors.add :Metrics,
                    "Incorrect Metric name or Metric not available: "\
                   "#{name}"
    _render_errors
  end

  def existing_metric? name
    Card.fetch_type_id(name) == MetricID
  end

  def hr
    "<hr />"
  end

  def hidden_source_field
    return unless (source = Env.params[:source])
    hidden_field "hidden_source", value: source
  end

  def company_field
    field_nest :wikirate_company, title: "Company"
  end

  def metric_field
    field_nest :metric, title: "Metrics"
  end

  def next_button
    wrap_with :div, class: "col-md-6 col-centered text-center" do
      submit_button text: "Next"
    end
  end
end
