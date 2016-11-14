# use for the filters on the "browse ..." pages

include_set Abstract::Filter
include_set Type::SearchType

def sort?
  true
end

def shift_sort_table?
  return false if Env.params["sort"] == "name"
  true
end

def default_sort_by_key
  "metric"
end

def filter_keys
  %w(metric designer wikirate_topic project year)
end

def advanced_filter_keys
  []
end

# gather all the params keys from default and advanced
def params_keys
  filter_keys + advanced_filter_keys
end

def filter_class
  Abstract::FilterQuery::Filter
end

def filter_wql
  filter_class.new(filter_keys_with_values, extra_filter_args).to_wql
end

def extra_filter_args
  { type_id: target_type_id }
end

def target_type_id
  WikirateCompanyID
end

def get_query params={}
  search_args = filter_wql
  sort_by search_args, Env.params["sort"] if sort?
  params[:query] = search_args
  super(params)
end

# the default sort will take the first table in the join
# I need to override to shift the sort table to the next one
def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  shift_sort_table query
  query.run
end

def shift_sort_table query
  if sort? && shift_sort_table?
    # sort table alias always stick to the first table,
    # but I need the next table
    sort = query.mods[:sort].scan(/c(\d+).db_content/).last.first.to_i + 1
    query.mods[:sort] = "c#{sort}.db_content"
  end
end

def sort_by wql, sort_by
  if sort_by == "name"
    wql[:sort] = "name"
  else
    wql[:sort_as] = "integer"
    wql[:dir] = "desc"
    wql[:sort] = {
      right: (sort_by || default_sort_by_key), right_plus: "*cached count"
    }
  end
end

def virtual?
  true
end

def raw_content
  %({ "name":"dummy" })
end


format :html do
  # view :no_search_results do |_args|
  #   wrap_with :div, "No result", class: "search-no-results"
  # end

  view :filter_form do |args|
    action = card.left.name
    wrap_with :form, action: "/#{action}", method: "GET" do
      [
        _optional_render(:sort_formgroup),
        main_filter_formgroups,
        advanced_filter_formgroups,
        filter_button_formgroup
      ]
    end
  end

  # it was from filter_search.rb
  # the filter args need to be included in the page link args
  # otherwise it will lose the filter condition while changing pages
  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    page_link_params.each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = @paging_path_args.merge filter_args
    link_to raw(text), options
  end

  def filter_button_formgroup
    button_formgroup do
      [advanced_button, reset_button]
    end
  end

  def reset_button
    link_to_card(card.cardname.left_name, "Reset",
                 class: "slotter btn btn-default margin-8")
  end

  def advanced_button
    toggle_text = filter_advanced_active? ? "Hide Advanced" : "Show Advanced"
    content_tag :a, toggle_text,
                 href: "#collapseFilter",
                 class: "btn btn-default",
                 data: { toggle: "collapse",
                         collapseintext: "Hide Advanced",
                         collapseouttext: "Show Advanced" }
  end

  def advanced_filter_formgroups
    return "".html_safe unless advanced_filter_keys
    wrap_as_collapse do
      super
    end
  end

  def wrap_as_collapse
    <<-HTML
     <div class="advanced-options">
      <div id="collapseFilter" class="collapse #{'in' if filter_active?}">
        #{yield}
      </div>
    </div>
    HTML
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

end
