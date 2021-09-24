format :html do
  view :source_phase, template: :haml, cache: :never

  def report_type
    metric_card.report_type_card.first_name
  end

  def default_source_filters
    {
      company_name: company_name,
      report_type: report_type,
      year: params[:year]
    }
  end

  def source_fields
    { wikirate_company: company_name,
      report_type: report_type }.each_with_object({}) do |(key, value), hash|
      hash["_#{key.cardname}"] = value
    end
  end
end
