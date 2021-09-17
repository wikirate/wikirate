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
      filter_by_companies query
      filter_by_year query
    end
  end

  def filter_keys
    %i[name company_group]
  end

  private

  def filter_by_year query
    return unless (year_value = Env.params.dig :filter, :year)

    query.merge! year_constraint(year_value)
  end

  def year_constraint year_value
    if year_value.try(:to_sym) == :latest
      { latest: true }
    else
      { year: year_value }
    end
  end

  def filter_by_companies query
    return unless company_ids.present?

    query[company_field] = ["in"] + company_ids
  end

  def company_field
    metric_card.inverse? ? :object_company_id : :subject_company_id
  end

  def company_ids
    @company_ids ||= params[:filter] ? filtered_company_ids : []
  end
end
