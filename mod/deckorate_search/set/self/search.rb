TYPES = %i[company topic metric dataset project
           source research_group company_group].freeze

include_set Abstract::OpenSearch
include_set Abstract::Breadcrumbs
include_set Abstract::FluidLayout

def search parameters={}
  # puts parameters
  os_search? ? os_search(parameters) : super
end

format do
  def featured_type_ids
    %i[cardtype featured].card.item_ids - [AnswerID]
  end

  def filter_type_ids
    type_param ? [type_param.card_id] : featured_type_ids
  end

  def featured_type_names
    featured_type_ids.map { |id| id.cardname.vary :plural }
  end

  def search_with_params
    requiring_keyword { os_search? ? matches_or_identifiers : super }
  end

  private

  def matches_or_identifiers
    results = os_search_returning_cards
    results.present? ? results : identifier_search
  end

  def identifier_search
    identifier_options.map { |result| os_result_card(result) }
  end

  def identifier_options
    card.os_search(index: "companies", body: { query: identifier_query })
      &.dig("hits", "hits")
  end

  def identifier_query
    { term: { company_identifiers: search_keyword } }
  end

  def requiring_keyword
    search_keyword.present? ? yield : []
  end
end

format :html do
  before :title do
    scope = type_param.present? ? h(type_param) : "all data"
    voo.title = "Search within #{scope}"
  end

  view :title, cache: :never do
    super()
  end

  view :page, template: :haml
  view :search_types, template: :haml, cache: :never
  view :titled_content, template: :haml

  view :search_box, cache: :never do
    search_form do
      wrap_with :div, class: "input-group search-box-input-group" do
        [select_type_tag, search_box_contents, haml(:search_button)]
      end
    end
  end

  def breadcrumb_items
    [link_to("Home", href: "/"), "Search Results"]
  end

  # @return [Integer]
  # (overrides default Decko method)
  def count_with_params
    os_search? ? os_count_with_params : super
  end

  def select_type_tag
    select_tag "query[type]", type_options, class: "search-box-select-type form-select"
  end

  def type_options
    options_for_select [["All Categories", ""],
                        ["--------------", "hr"]] + featured_type_names,
                       selected: query_params[:type],
                       disabled: :hr
  end

  def link_to_type typecode, text: nil
    typename = typecode.cardname

    link_to_card :search, (text || "#{icon_tag typecode} #{typename&.vary :plural}"),
                 path: { query: { type: typename, keyword: search_keyword } },
                 class: "me-3 my-1 badge filter-chip " \
                        "bg-#{typename.present? ? typename.key : 'secondary'}-outline"
  end

  def link_without_type text, args={}
    link_to_card :search, text, args.merge(path: { query: { keyword: search_keyword } })
  end

  def search_item term
    haml :search_item, term: term
  end
end

format :json do
  view :search_box_complete, cache: :never, perms: :none do
    search_box_items :goto_items, :search_item
  end

  # Retrieves Open Search results for autocompletion in
  # the main search box
  # @return [Array] list of card names
  # (overrides default Decko method)
  def complete_or_match_search *args
    return super(**args.first) unless os_search?

    results = cardnames_from_os_results { autocomplete_options }
    return results if results.present?

    cardnames_from_os_results { identifier_options }
  end

  def go_to_exact_match? exact
    exact.known? && TYPES.include?(exact.type_code)
  end

  private

  def cardnames_from_os_results
    requiring_keyword do
      yield.map { |result| os_result_card(result)&.cardname }.compact
    end
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
