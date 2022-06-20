TYPES = %i[wikirate_company wikirate_topic metric project
           dataset research_group].freeze

def cql_content
  { type: ([:in] + TYPES),
    fulltext_match: "$keyword",
    sort_by: "relevance" }
end

format :html do
  def search_params
    super.tap { |p| p[:type] = query_params[:type] if query_params[:type].present? }
  end

  view :search_box do
    search_form do
      wrap_with :div, class: "input-group search-box-input-group" do
        [select_type_tag, search_box_contents]
      end
    end
  end

  def select_type_tag
    select_tag "query[type]", type_options, class: "search-box-select-type form-select"
  end

  def type_options
    options_for_select [["Any Type", ""] + TYPES.map(&:cardname)]
  end
end
