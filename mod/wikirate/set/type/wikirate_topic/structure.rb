include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image]
  end

  def tab_list
    %i[details wikirate_company post project]
  end

  view :data, cache: :never do
    with_header "Metrics" do
      field_nest :metric, view: :metric_by_company_count,
                          items: { view: :listing }
    end
  end

  view :details_tab do
    field_nest :general_overview, view: :titled
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :company_list_with_metric_counts
  end

  view :project_tab do
    field_nest :project, items: { view: :listing }
  end

  view :browse_item, template: :haml
  view :homepage_item, template: :haml
  view :homepage_item_sm, template: :haml
end
