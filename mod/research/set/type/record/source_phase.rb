format :html do
  view :source_phase, template: :haml

  def default_source_filters
    {
      # wikirate_company: card.company_name,
      report_type: card.metric_card.report_type,
      year: ""
    }
  end
end
