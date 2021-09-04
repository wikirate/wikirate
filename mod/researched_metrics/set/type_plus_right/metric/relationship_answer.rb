include_set Abstract::MetricChild, generation: 1
include_set Abstract::PublishableField

def query
  { metric_card.metric_lookup_field => metric_id }
end

def item_type
  :relationship_answer
end

format do
  def relationship_query
    card.query.tap do |query|
      if subject_company_ids.present?
        query.merge! subject_company_id: subject_company_ids.unshift("in")
      end
    end
  end

  def subject_company_ids
    @subject_company_ids ||= Env.params[:filter] ? filtered_company_ids : []
  end

  def filter_keys
    %i[name company_group]
  end
end
