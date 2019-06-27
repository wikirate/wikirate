include_set Abstract::Tabs
include_set Abstract::Filterable

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

  view :record_button do
    filter_for_record do
      button_tag "#{card.record_card.count}-Year Record",
                 class: "btn-sm mt-3 mb-1", situation: "secondary"
    end
  end

  def filter_for_record
    filterable record_filter_hash, class: "d-inline" do
      yield
    end
  end

  def record_filter_hash
    { status: :exists,
      metric_name: exactly(card.metric_name),
      company_name: exactly(card.company_name) }
  end

  def exactly name
    %("#{Card.fetch_name name}")
  end

  def details_top
    class_up "full-page-link", "metric-color"
    haml :details_top
  end

  view :basic_details do
    render_concise hide: :year_and_icon
  end

  view :details_sidebar do
    wrap { filtering(".RIGHT-answer ._filter-widget") { haml :details_sidebar } }
  end

  view :company_details_sidebar do
    detail_variant do
      render_details_sidebar hide: :metric_header
    end
  end

  # used in metric values list on a company page
  view :metric_details_sidebar do
    detail_variant do
      render_details_sidebar hide: :company_header
    end
  end

  view :company_header do
    nest card.company_card, view: :shared_header
  end

  def detail_variant
    wrap_with(:div, "data-details-view": @current_view) { yield }
  end

  view :metric_header do
    nest card.metric_card, view: :shared_header
  end
end
