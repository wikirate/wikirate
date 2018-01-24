include_set Abstract::Media
card_accessor :metric
card_accessor :wikirate_company

format :html do
  view :open do
    voo.hide :menu
    super()
  end

  view :content do
    _render_core
  end

  view :core, cache: :never do
    render_slot_machine
  end

  def field_content_from_params
    if params[:metric] || project
      card.metric_card.update_attributes! content: metrics.to_pointer_content
    end
    if params[:company]
      card.company_card.content.update_attributes! content: params[:company]
    end
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
