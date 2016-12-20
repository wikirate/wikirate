include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image]
  end

  def tab_list
    {
      details_tab: two_line_tab("Details", fa_icon("info")),
      companies_tab: tab_count_title(:wikirate_company),
      projects_tab: tab_count_title(:project)
    }
  end

  view :data, cache: :never do
    metric_tab
  end

  def metric_tab
    wrap do
      [metric_filter, metric_table]
    end
  end

  def metric_filter
    field_subformat(:topic_metric_filter)._render_core
  end

  view :details_tab do
    field_nest :general_overview, view: :titled
  end

  view :companies_tab do
    field_nest :wikirate_company, view: :company_list_with_metric_counts
  end

  view :projects_tab do
    field_nest :project, items: { view: :listing }
  end

end
