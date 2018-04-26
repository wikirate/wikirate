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

format :json do
  view :related_companies_with_year do
    card.related_companies_with_year.to_json
  end
end

# format :html do
#   # TODO: following are dummy views for now (see expanded_record.rb)
#
#   view :core do
#     output [
#       render_metric_listing,
#       render_company_listing,
#       render_answer_table
#     ]
#   end
#
#   view :expanded_from_company do
#     render :core, hide: :company_listing
#   end
#
#   view :expanded_from_metric do
#     render :core, hide: :metric_listing
#   end
#
#   view :metric_listing do
#     nest metric_card, view: :listing
#   end
#
#   view :company_listing do
#     nest company_card, view: :listing
#   end
#
# end

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
  wql = { left: { type_id: MetricValueID, left: left_left },
          right: right }
  hwa = Hash.new { |h, k| h[k] = [] }
  Card.search(wql).each_with_object(hwa) do |card, h|
    hkey = key.call(card)
    h[hkey] = (h[hkey] << card.name.left_name.right_name).sort.reverse
  end
end
