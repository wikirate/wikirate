include_set Abstract::BrowseFilterForm
def filter_words
  [:wikirate_company, :wikirate_topic, :wikirate_tag].map do |field|
    Env.params[field]
  end.flatten.compact
end

def params_keys
  []
end

def filter_keys
  %w(claimed cited company topic)
end

def advanced_filter_keys
  []
end

def get_query params={}
  search_args = { limit: 15 }
  search_args.merge! sort_query
  search_args.merge! cited_query
  search_args.merge! claimed_query
  search_args[:type] = left.name
  params[:query] = Card.tag_filter_query(
    filter_words,
    search_args,
    %w(tag company topic)
  )
  super(params)
end

def cited_query
  cited = { referred_to_by: { left: { type_id: WikirateAnalysisID },
                              right_id: OverviewID } }
  case Env.params[:cited]
  when "yes" then cited
  when "no"  then { not: cited }
  else            {}
  end
end

def claimed_query
  yes_query = { linked_to_by: { left: { type_id: ClaimID },
                                right_id: SourceID } }
  case Env.params[:claimed]
  when "yes" then yes_query
  when "no"  then { not: yes_query }
  else            {}
  end
end

def sort_query
  if Env.params[:sort] == "recent"
    { sort: "update" }
  else
    { sort: { "right" => "*vote count" }, sort_as: "integer", dir: "desc" }
  end
end

format :html do
  def page_link_params
    [:sort, :cited, :claimed, :wikirate_company, :wikirate_topic]
  end

  view :no_search_results do |_args|
    wrap_with :div, "No result", class: "search-no-results"
  end

  def sort_options
    super.merge "Most Important" => "important",
                "Most Recent" => "recent"
  end

  def default_sort_option
    "important"
  end

  view :cited_formgroup do |_args|
    options = { "All" => "all", "Yes" => "yes", "No" => "no" }
    simple_select_filter :cited, options, "all", "Cited"
  end

  view :claimed_formgroup do |_args|
    options = { "All" => "all", "Yes" => "yes", "No" => "no" }
    simple_select_filter :claimed, options, "all", "Has Notes?"
  end

  view :company_formgroup do
    multiselect_filter :wikirate_company, "Company"
  end

  view :topic_formgroup do
    multiselect_filter :wikirate_topic, "Topic"
  end

  view :tag_formgroup do
    multiselect_filter :wikirate_tag, "Tag"
  end
end
