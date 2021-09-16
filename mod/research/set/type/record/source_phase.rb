format :html do
  view :source_phase, template: :haml, cache: :never

  def default_source_filters
    {
      company_name: card.company_name,
      report_type: card.metric_card.report_type_card.first_name,
      year: ""
    }
  end
end
