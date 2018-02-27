def value year
  Answer.where(record_id: id, year: year.to_i).pluck(:value).first
end

def answer year
  Answer.where(record_id: id, year: year.to_i).first
end

def answers_by_year
  @aby ||=
    Answer.where(record_id: id).each_with_object({}) do |a, h|
      h[a.year] = a
      h[a.year.to_s] = a
    end
end

def related_companies_with_year
  return {} unless metric_card.relationship?
  if metric_card.inverse?
    related_companies_of_inverse_metric
  else
    related_companies_of_relationship_metric
  end
end

def related_companies_of_relationship_metric
  wql = {
          left: {
            left: { left_id: metric_card.id, right_id: right_id },
            type_id: MetricValueID
          },
          right: { type_id: WikirateCompanyID }
        }
  hwa = Hash.new { |h,k| h[k] = [] }
  Card.search(wql).each_with_object(hwa) do |card, h|
    h[card.name.right_name] << card.name.left_name.right_name
  end
end

def related_companies_of_inverse_metric
  wql = {
          left: {
            left: { left_id: metric_card.inverse_card.id },
            type_id: MetricValueID
          },
          right_id: right_id
        }
  hwa = Hash.new { |h,k| h[k] = [] }
  Card.search(wql).each_with_object(hwa) do |card, h|
    h[card.name.left_name.left_name.right_name] << card.name.left_name.right_name
  end
end



format :json do
  view :related_companies_with_year do
    card.related_companies_with_year.to_json
  end
end
