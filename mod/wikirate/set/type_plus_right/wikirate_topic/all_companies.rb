include_set Abstract::SortAndFilter

def related_via_source_or_note
  %(
    "referred_to_by": {
      "left": {
        "type": ["in", "Note", "Source"],
        "right_plus": ["topic", { "refer_to": "#{name}" } ]
      },
      "right": "company"
    }
  )
end

def related_via_metric
  %(
    "left_plus": [
      {
        "type": "metric",
        "right_plus": ["topic", { "refer_to": "#{name}" }]
      },
      {
        "right_plus": ["*cached_count", { "content": ["ne", "0"] }]
      }
    ]
  )
end

def raw_content
  # search looks like this but is not used
  # instead the json core view delivers the search result
  # calling #related_companies of the topic card
  %({
    "type": "company",
    "or": { #{related_via_source_or_note}, #{related_via_metric} }
  })
end

def related_company_ids_to_json ids
  ids.each_with_object({}) do |company_id, result|
    result[company_id] = true unless result.key?(company_id)
  end.to_json
end

format :json do
  view :core do
    card.related_company_ids_to_json card.left.related_companies
  end
end

format do
  def analysis_cached_count company, type
    search_card = Card.fetch "#{company}+#{card.cardname.left}+#{type}"
    count_card = search_card.fetch trait: :cached_count, new: {}
    count_card.format.render_core.to_i
  end

  def page_link_params
    [:name, :sort]
  end
end
