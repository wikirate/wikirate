format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image]
  end

  view :core do
    return super() if voo.structure
    wikirate_layout "topic",
                    [["company", "Companies", "+company+*cached count"],
                     ["overview", "Review", "+Review+*count"],
                     ["metric", "Metrics", "+metric count"],
                     ["note", "Notes", "+note+*count"],
                     ["reference", "Sources", "+source+*count"]]
  end

  view :metric_tab do
    wrap do
      [metric_filter, metric_table]
    end
  end

  view :company_tab do
    wrap do
      [company_filter, company_table]
    end
  end

  def company_filter
    field_subformat(:topic_company_filter)._render_core
  end

  def metric_filter
    field_subformat(:topic_metric_filter)._render_core
  end
end
