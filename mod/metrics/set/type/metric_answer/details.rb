include_set Abstract::Tabs
include_set Abstract::Filterable

format :html do
  def tab_list
    list = [:details]
    list << :metric if voo.show? :metric_header
    list << :wikirate_company if voo.show? :company_header
    list
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

  # view :year_tab do
  #   nest card.record_card, view: :data
  # end

  view :details do
    [details_top, render_expanded_details]
  end

  view :record_links, cache: :never do
    return unless record_count > 1
    wrap_with :div, class: "record-links text-muted" do
      [render_record_filter_link, other_year_links]
    end
  end

  def other_record_answers
    card.record_card.researched_answers.reject { |a| a.year == card.year }
  end

  def other_year_links
    wrap_with :div, class: "other-year-links" do
      other_record_answers.map do |answer|
        link_to "#{mapped_icon_tag :year} #{answer.year}",
                href: answer.name.url_key, class: "_update-details year-detail"
      end.join "<span>, </span>"
    end
  end

  def record_count
    @record_count ||= card.record_card.count
  end

  view :record_filter_link, cache: :never do
    filter_for_record do
      "#{icon_tag :album} #{record_count}-Year Record"
    end
  end

  def filter_for_record
    filterable record_filter_hash, class: "record-filter" do
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
