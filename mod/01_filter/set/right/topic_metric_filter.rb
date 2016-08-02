def virtual?
  true
end

format :html do
  include Set::Right::CompanyMetricFilter::HtmlFormat
  def filter_categories
    %w(name research_policy metric_type)
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
          <form action="/#{action}?view=content_left_col" method="GET" data-remote="true" class="slotter">
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
    args[:title] = "Metric Name"
  end

  def metric_filter_fields args
    [
      _optional_render(:name_formgroup, args),
      _optional_render(:research_policy_formgroup, args),
      _optional_render(:metric_type_formgroup, args),
      _optional_render(:sort_formgroup, args)
    ]
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Importance to Community (up-voted by community)" => "upvoted",
      "Most Company" => "company_number",
      "Metric Designer (Alphabetical)" => "metric_designer",
      "Metric Title (Alphabetical)" => "metric_title"
    }
    args[:sort_option_default] = "upvoted"
  end
end
