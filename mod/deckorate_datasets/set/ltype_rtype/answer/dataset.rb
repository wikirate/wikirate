include_set Abstract::CqlSearch

def cql_content
  {
    type: :dataset,
    right_plus: [
      { id: [:in, CompanyID, MetricId] },
      { refer_to: { id: [:in, left.company_id, left.metric_id] } }
    ]
  }
end
