include_set Abstract::MetricChild, generation: 2
include_set Abstract::SourceSearch

format :html do
  before :filtered_content do
    voo.filter = filter_hash
  end

  view :compact_filter_form do
    super() + haml(:source_help)
  end

  def current_year
    params[:year]
  end

  def report_type
    metric_card.report_type_card.item_names
  end

  def company_name
    card.company_name.standard
  end

  def new_source_defaults
    {
      company: company_name,
      report_type: report_type,
      year: current_year
    }.each_with_object({}) do |(key, value), hash|
      hash["_#{key.cardname}"] = value
    end
  end

  def default_filter_hash
    {
      wikirate_link: "",
      company: company_name,
      report_type: report_type,
      year: current_year
    }
  end

  def default_limit
    18
  end
end
