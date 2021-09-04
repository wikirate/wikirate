include_set Abstract::MetricChild, generation: 1

def query
  { metric_card.metric_lookup_field => metric_id }
end

def item_type
  :relationship_answer
end

format do
  # only handles subject company and year for now.
  def relationship_query
    card.query.tap do |query|
      filter_by_subject_companies query
      filter_by_year query
    end
  end

  def filter_by_year query
    return unless (year = year_from_params)

    if year.try(:to_sym) == :latest
      query[:latest] = true
    else
      query[:year] = year
    end
  end

  def year_from_params
    Env.params.dig :filter, :year
  end

  def filter_by_subject_companies query
    return unless subject_company_ids.present?

    query[:subject_company_id] = subject_company_ids.unshift("in")
  end

  def subject_company_ids
    @subject_company_ids ||= Env.params[:filter] ? filtered_company_ids : []
  end

  def filter_keys
    %i[name company_group]
  end
end
