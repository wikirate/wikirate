TYPES = %i[wikirate_company wikirate_topic metric dataset project
           source research_group company_group].freeze

def cql_content
  { type: ([:in] + TYPES),
    fulltext_match: "$keyword",
    sort_by: "relevance" }
end

format :html do
  def search_params
    super.tap { |p| p[:type] = search_type if search_type }
  end

  view :search_box, cache: :never do
    search_form do
      wrap_with :div, class: "input-group search-box-input-group" do
        [select_type_tag, search_box_contents]
      end
    end
  end

  view :search_types, template: :haml, cache: :never

  view :core do
    voo.items = { view: :result_bar }
    [render_search_types, render_results_for_keyword, super()]
  end

  def search_type_codenames
    TYPES
  end

  def search_type
    query_params[:type].present? && query_params[:type]
  end

  def select_type_tag
    select_tag "query[type]", type_options, class: "search-box-select-type form-select"
  end

  def type_options
    options_for_select [["All Types", ""]] + TYPES.map(&:cardname), query_params[:type]
  end

  def link_to_type typecode, text=nil
    typename = typecode.cardname
    link_to_card :search, (text || typename&.vary(:plural)),
                 path: { query: { type: typename, keyword: search_keyword } },
                 class: "mx-2 my-1 badge " \
                        "bg-#{typename.present? ? typename.key : 'secondary'}"
  end
end

format :json do
  view :search_box_complete, cache: :never do
    term_and_exact do |term, exact|
      { term: term, goto: goto_items(term, exact) }
    end
  end
end
