def virtual?
  true
end

format :html do
  include Set::Right::CompanyMetricFilter::HtmlFormat
  def filter_categories
    %w(name)
  end

  def default_button_formgroup_args args
    args[:buttons] = [
      card_link(card.left, path_opts: { view: :company_tab },
                           text: "Reset",
                           class: "slotter btn btn-default margin-8",
                           remote: true),
      button_tag("Filter", situation: "primary", disable_with: "Filtering")
    ].join
  end

  view :core do |args|
    action = card.cardname.left_name.url_key
    filter_active = filter_active? ? "block" : "none"
    <<-HTML
    <div class="filter-container">
        <div class="filter-header">
          <span class="glyphicon glyphicon-filter"></span>
          Filter & Sort
          <span class="filter-toggle">
            <span class="glyphicon glyphicon-triangle-right"></span>
          </span>
        </div>
        <div class="filter-details" style="display: #{filter_active};">
          <form action="/#{action}?view=company_tab" method="GET" data-remote="true" class="slotter">
            <div class="margin-12 sub-content"> #{metric_filter_fields(args).join} </div>
            <div class="filter-buttons">
              #{_optional_render :button_formgroup, args}
            </div>
          </form>
        </div>
    </div>
    HTML
  end

  def default_name_formgroup_args args
    args[:title] = "Company"
  end

  def metric_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:sort_formgroup, args)
    ]
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Metrics" => "most_metrics",
      "Most Notes" => "most_notes",
      "Most Sources " => "most_sources",
      "Has Overview" => "has_overview"
    }
    args[:sort_option_default] = "most_metrics"
  end
end
