include_set Abstract::BrowseFilterForm

class CompanyFilter < Abstract::FilterQuery::Filter
  INDUSTRY_METRIC_NAME = "Global Reporting Initiative+Sector Industry"
  INDUSTRY_VALUE_YEAR = "2015"
  def wikirate_topic_wql value
    add_to_wql :found_by, value.to_name.trait(:wikirate_company)
  end

  def industry_wql industry
    return unless industry.present?
    @filter_wql[:left_plus] << [
        CompanyFilter::INDUSTRY_METRIC_NAME,
        { right_plus: [
            CompanyFilter::INDUSTRY_VALUE_YEAR,
            { right_plus: ["value", { eq: industry }] }
        ] }
    ]
  end
end

def filter_keys
  %w(name industry)
end

def advanced_filter_keys
  %w(project wikirate_topic)
end

def filter_class
  CompanyFilter
end

format :html do
  def sort_options
    {
      "Alphabetical" => "name",
      "Most Metrics" => "metric",
      "Most Topics" => "topic"
    }
  end

  def default_sort_option
    "metric"
  end
end
