include_set Abstract::Tabs

format :html do
  def tab_list
    list = [:details]
    list << :metric if voo.show? :metric_header
    list << :wikirate_company if voo.show? :company_header
    list
  end

  def tab_options
    {
      lines: 1,
      details:          { label: "Answer" },
      metric:           { label: "Metric" },
      wikirate_company: { label: "Company" }
    }
  end

  view :details_tab do
    render_details
  end

  view :metric_tab do
    nest card.metric_card, view: :details_tab
  end

  view :wikirate_company_tab do
    nest card.company_card, view: :details_tab
  end

  view :details do
    [render_year_and_value_pretty, render_expanded_details]
  end

  view :basic_details do
    render_concise hide: :year_and_icon
  end

  view :details_sidebar, template: :haml

  view :company_details_sidebar do
    voo.hide :metric_header
    haml :details_sidebar
  end

  # used in metric values list on a company page
  view :metric_details_sidebar do
    voo.hide :company_header
    haml :details_sidebar
  end

  view :company_header do
    nest card.company_card, view: :rich_header, hide: :menu
  end

  view :metric_header do
    nest card.metric_card, view: :rich_header, hide: :menu
  end
end
