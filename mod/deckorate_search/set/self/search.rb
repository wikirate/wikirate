TYPES = %i[wikirate_company wikirate_topic metric dataset project
           source research_group company_group].freeze

include_set Abstract::OpenSearch

def search parameters={}
  os_search? ? os_search(parameters) : super
end

format do
  def search_type_codenames
    TYPES
  end

  def filter_type_ids
    type_param ? [type_param.card_id] : search_type_codenames.map(&:card_id)
  end
end

format :html do
  def search_with_params
    os_search? ? os_search_returning_cards : super
  end

  # @return [Integer]
  # (overrides default Decko method)
  def count_with_params
    os_search? ? os_count_with_params : super
  end

  view :search_box, cache: :never do
    search_form do
      wrap_with :div, class: "input-group search-box-input-group" do
        [select_type_tag, search_box_contents, haml(:search_button)]
      end
    end
  end

  view :search_types, template: :haml, cache: :never

  view :core do
    voo.items = { view: :result_bar }
    [render_search_types, render_results_for_keyword, super()]
  end

  def select_type_tag
    select_tag "query[type]", type_options, class: "search-box-select-type form-select"
  end

  def type_options
    options_for_select [["All Categories", ""],
                        ["--------------", "hr"]] + TYPES.map(&:cardname),
                       selected: query_params[:type],
                       disabled: :hr
  end

  def link_to_type typecode, text=nil
    typename = typecode.cardname
    link_to_card :search, (text || typename&.vary(:plural)),
                 path: { query: { type: typename, keyword: search_keyword } },
                 class: "mx-2 my-1 badge " \
                        "bg-#{typename.present? ? typename.key : 'secondary'}"
  end

  def search_item term
    haml :search_item, term: term
  end
end

format :json do
  view :search_box_complete, cache: :never do
    search_box_items :goto_items, :search_item
  end

  # Retrieves Open Search results for autocompletion in
  # the main search box
  # @return [Array] list of card names
  # (overrides default Decko method)
  def complete_or_match_search *args
    return super(**args.first) unless os_search?

    cardnames_from_os_results autocomplete_options
  end

  private

  def cardnames_from_os_results results
    return [] unless search_keyword.present?

    results.map { |result| result["_id"]&.to_i&.cardname }
  end

  def autocomplete_options
    card.search(body: { suggest: suggestion_query })
      &.dig("suggest", "autocomplete")
      &.first&.dig "options"
  end

  # suggest_query
  def suggestion_query
    { autocomplete: { prefix: search_keyword,
                      completion: { field: "autocomplete_field",
                                    contexts: { type_id: suggest_contexts } } } }
  end

  # constructs the context filtering clause for the suggest_query
  # in case of multiple contexts we are favoring other contexts than source
  def suggest_contexts
    filter_type_ids.map do |type_id|
      { context: type_id, boost: (type_id == :source.card_id ? 1 : 2) }
    end
  end
end
