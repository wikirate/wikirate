format :html do
  # ANSWER DETAILS ON RECORDS
  # company and/or metrics are detailed separately,
  # so details only include value, year, etc.

  view :details do
    [render_year_and_value_pretty, render_expanded_details]
  end

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
