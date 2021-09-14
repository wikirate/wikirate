format :html do
  def project_card
    @project_card || params[:project]&.card
  end

  layout :research_layout, view: :research do
    wikirate_layout "wikirate-one-full-column-layout research-layout px-2" do
      layout_nest
    end
  end

  def layout_for_view view
    :research_layout if view == :research
  end

  view :research, template: :haml

  view :research_progress_bar do
    nest Card.fetch([card.company_name, project_card]), view: :research_dashboard_progress
  end
end
