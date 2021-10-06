include_set Abstract::MetricChild, generation: 2
include_set Abstract::SourceFilter

format :html do
  def current_year
    params[:year]
  end

  def report_type
    metric_card.report_type_card.first_name
  end

  def company_name
    # need fetch_name to standardize
    Card.fetch_name card.company_name
  end

  def new_source_defaults
    {
      wikirate_company: company_name,
      report_type: report_type,
      year: current_year
    }.each_with_object({}) do |(key, value), hash|
      hash["_#{key.cardname}"] = value
    end
  end

  def default_filter_hash
    {
      wikirate_link: "",
      company_name: company_name,
      report_type: report_type,
      year: current_year
    }
  end

  def default_limit
    18
  end
end
