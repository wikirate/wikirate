format :html do
  def project_card
    @project_card || params[:project]&.card
  end

  def project_name
    project_card&.name
  end

  def project_companies_mark
    project_name.field :wikirate_company
  end

  def project_metrics_mark
    project_name.field :metric
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
  private

  def research_header type
    base = card.send "#{type}_name"
    nest Card.fetch([base, project_card]), view: :research_header
  end
end
