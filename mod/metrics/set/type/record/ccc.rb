# special API for CCC widget.
#
# TODO: update to use relationships table!

format :json do
  view :related_companies_with_year do
    card.related_companies_with_year.to_json
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

private

def related_companies_of_relationship_metric
  search_companies left_left: { left_id: metric_card.id, right_id: right_id },
                   right: { type_id: WikirateCompanyID },
                   key: ->(card) { card.name.right_name }
end

def related_companies_of_inverse_metric
  search_companies left_left: { left_id: metric_card.inverse_card.id },
                   right: { id: right_id },
                   key: ->(card) { card.name.left_name.left_name.right_name }
end

def search_companies left_left:, right:, key:
  wql = { left: { type_id: MetricAnswerID, left: left_left },
          right: right }
  hwa = Hash.new { |h, k| h[k] = [] }
  Card.search(wql).each_with_object(hwa) do |card, h|
    hkey = key.call(card)
    h[hkey] = (h[hkey] << card.name.left_name.right_name).sort.reverse
  end
end
