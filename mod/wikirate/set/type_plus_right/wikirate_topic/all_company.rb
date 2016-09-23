include_set Abstract::SortAndFilter

RELATED_VIA_SOURCE_OR_NOTE =
  %(
    "referred_to_by": {
      "left": {
        "type": %w(in Note Source),
        "right_plus": ["topic", "refer_to": #{name}]
      },
      "right": "company"
    },
    }
  ).freeze
RELATED_VIA_METRIC =
  %(
    "left_plus": [
      {
        "type": "metric",
        "right_plus": ["topic", { "refer_to": #{name} }]
      },
      {
        "right_plus": ["*cached_count", { "content": ["ne", "0"] }]
      }
    ]
  ).freeze

def related_company_from_metric

def raw_content
  # search looks like this but is not used
  # instead the json core view delivers the search result
  # calling #related_companies of the topic card
  %({
    "type": "company",
    "or": { #{RELATED_VIA_SOURCE_OR_NOTE}, #{RELATED_VIA_METRIC} }
  })
end

def pass_filter? key, _values
  filter_by_name key
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
  def sort_by
    @sort_by ||= Env.params["sort"] || "most_metrics"
  end

  def sort_order
    "desc"
  end

  def analysis_cached_count company, type
    search_card = Card.fetch "#{company}+#{card.cardname.left}+#{type}"
    count_card = search_card.fetch trait: :cached_count, new: {}
    count_card.format.render_core.to_i
  end

  def sort_by_desc companies, type
    companies.sort do |x, y|
      value_a = analysis_cached_count x[0], type
      value_b = analysis_cached_count y[0], type
      value_b - value_a
    end
  end

  def overview? company
    Card.exists?("#{company}+#{card.cardname.left}+review") ? 1 : 0
  end

  def sort_by_overview companies
    companies.sort do |x, y|
      x_overview = overview?x[0]
      y_overview = overview?y[0]
      if x_overview == y_overview
        x[0] <=> y[0]
      else
        y_overview - x_overview
      end
    end
  end

  def sorted_result
    cached_values = card.filtered_values_by_name
    case sort_by
    when "most_notes"
      sort_by_desc cached_values, "note"
    when "most_sources"
      sort_by_desc cached_values, "source"
    when "has_overview"
      sort_by_overview cached_values
    else # "most_metrics"
      sort_by_desc cached_values, "metric"
    end
  end

  def page_link_params
    [:name, :sort]
  end
end
