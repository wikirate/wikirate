include_set Abstract::Filter
def get_query params={}
  filter_words =  Array.wrap(Env.params[:company]) || []
  filter_words += Array.wrap(Env.params[:topic]) if Env.params[:topic]
  filter_words += Array.wrap(Env.params[:tag])   if Env.params[:tag]
  search_args = { limit: 15 }
  search_args.merge! sort_query
  search_args.merge! cited_query
  search_args.merge! claimed_query
  search_args[:type] = left.name
  params[:query] = Card.tag_filter_query(
    filter_words,
    search_args,
    %w( tag company topic )
  )
  super(params)
end

def cited_query
  yes_query = { referred_to_by: { left: { type_id: WikirateAnalysisID },
                                  right_id: OverviewID } }
  case Env.params[:cited]
  when "yes" then yes_query
  when "no"  then { not: yes_query }
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
    { :sort => { "right" => "*vote count" },
      "sort_as" => "integer", "dir" => "desc" }
  end
end

format :html do
  def page_link_params
    [:sort, :cited, :claimed, :company, :topic, :tag]
  end

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    page_link_params.each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    link_to raw(text), path(@paging_path_args.merge(filter_args)), options
  end

  view :no_search_results do |_args|
    %(
      <div class="search-no-results">
        No result
      </div>
    )
  end

  view :filter_form do |args|
    # args[:buttons] = button_tag 'Filter', :class=>'submit-button', :disable_with=>'Filtering'
    content = output([
                       optional_render(:sort_formgroup, args),
                       optional_render(:claimed_formgroup, args),
                       optional_render(:cited_formgroup, args),
                       optional_render(:company_formgroup, args),
                       optional_render(:topic_formgroup, args),
                       optional_render(:tag_formgroup, args),
                       # render( :button_formgroup, args )
                     ])
    action = card.left.name
    # action = 'Source' if action == 'Page'
    %( <form action="/#{action}" method="GET">#{content}</form>)
  end

  view :sort_formgroup do |_args|
    select_filter "sort",
                  options_for_select(
                    {
                      "Most Important" => "important",
                      "Most Recent" => "recent"
                    }, params[:sort] || "important")
  end

  view :cited_formgroup do |_args|
    select_filter "cited",
                  options_for_select(
                    {
                      "All" => "all", "Yes" => "yes", "No" => "no"
                    }, params[:cited] || "all")
  end

  view :claimed_formgroup do |_args|
    select_filter "Has Notes?",
                  options_for_select(
                    {
                      "All" => "all", "Yes" => "yes", "No" => "no"
                    }, params[:claimed] || "all")
  end

  view :company_formgroup do |args|
    multiselect_filter "company", args
  end

  view :topic_formgroup do |args|
    multiselect_filter "topic", args
  end

  view :tag_formgroup do |args|
    multiselect_filter "tag", args
  end

  def select_filter type_name, options, args={}
    formgroup type_name.capitalize,
              select_tag(type_name, options, class: "pointer-select"), args
  end

  def multiselect_filter type_name, _args
    options_card = Card.new name: "+#{type_name}"  # codename
    selected_options = params[type_name]
    options = options_for_select(options_card.option_names, selected_options)
    multiselect_tag = select_tag(type_name, options,
                                 multiple: true,
                                 class: "pointer-multiselect")
    formgroup(type_name.capitalize,
              multiselect_tag, class: "filter-input #{type_name}")
  end
end
