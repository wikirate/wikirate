include_set Abstract::Tabs

format :html do
  def tab_list
    list = [:details]
    list << :metric if voo.show? :metric_header
    list << :wikirate_company if voo.show? :company_header
    list << :year
  end

  def tab_options
    {
      details:          { label: "Answer" },
      metric:           { label: "Metric" },
      wikirate_company: { label: "Company" },
      year:             { label: "Years", count: record_card.count }
    }
  end

  def one_line_tab?
    true
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

  view :year_tab do
    nest card.record_card, view: :data
  end

  view :details do
    [details_top, render_expanded_details]
  end

  # def tmp_details
  #   [
  #     render_full_page_link,
  #     link_to("record", href: "#", class: "_record-filter",
  #             data: { filter: { key: "metric", value: "'#{card.metric_name}'"} } )
  #   ]
  # end

  def details_top
    class_up "full-page-link", "metric-color"
    haml :details_top
  end

  view :basic_details do
    render_concise hide: :year_and_icon
  end

  view :details_sidebar do
    wrap { haml :details_sidebar }
  end

  view :company_details_sidebar do
    render_details_sidebar hide: :metric_header
  end

  # used in metric values list on a company page
  view :metric_details_sidebar do
    render_details_sidebar hide: :company_header
  end

  view :company_header do
    nest card.company_card, view: :shared_header
  end

  view :metric_header do
    nest card.metric_card, view: :shared_header
  end
end
