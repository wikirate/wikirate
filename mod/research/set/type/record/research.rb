format :html do
  def project_card
    @project_card ||= params[:project]&.card
  end

  def dataset_card
    @dataset_card ||= project_card&.dataset_card
  end

  def project_name
    project_card&.name
  end

  def project_companies_mark
    project_name&.field :wikirate_company
  end

  def project_metrics_mark
    project_name&.field :metric
  end

  def company_project_mark
    company_name.field project_name
  end

  layout :research_layout, view: :research do
    wikirate_layout "wikirate-one-full-column-layout research-layout px-2" do
      layout_nest
    end
  end

  def layout_for_view view
    :research_layout if view&.to_sym == :research
  end

  view :research, template: :haml
  view :company_header, template: :haml
  view :metric_header, template: :haml
  view :metric_option, template: :haml

  def angle dir
    fa_icon "angle-#{dir}", class: "text-secondary"
  end

  def multi_company?
    dataset_card && dataset_card.num_companies > 1
  end

  def multi_metric?
    dataset_card && dataset_card.num_metrics > 1
  end

  def link_to_company
    link_to_card company_name, nil, class: "company-color", target: "_company"
  end

  def metric_ids
    @metric_ids ||= dataset_card&.metric_ids
  end

  def metric_index
    @metric_index ||= metric_ids.index card.metric_id
  end

  def link_to_metric index, text
    record_name = metric_id_for_index(index).cardname.field card.company_name
    link_to_card record_name, text, path: { project: project_name, view: :research }
  end

  def metric_id_for_index index
    return metric_ids.last if index.negative?

    metric_ids[index] || metric_ids.first
  end
end
