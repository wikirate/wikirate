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
  Card::FilterQuery
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

def build_query params={}
  search_args = filter_wql
  add_sort_wql search_args, sort_param if sort?
  params[:query] = search_args
  super(params)
end

# the default sort will take the first table in the join
# I need to override to shift the sort table to the next one
def item_cards params={}
  s = fetch_query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  shift_sort_table query
  query.run
end

# HenryHack® below!
# My guess is that sort queries like
# sort: { right: "value", right_plus: "*cached count" }
# are not supported by wql but the HenryHack® makes it work
# -pk
# evolved theory:
# There are two statements in the sort hash.
# wql uses the result of the first one for sorting, but we
# we want to sort by the result of the second statement
# and this shift stuff ensures that
# -pk
def shift_sort_table query
  if sort? && shift_sort_table?(query)
    # sort table alias always stick to the first table,
    # but I need the next table
    sort = query.mods[:sort].scan(/c(\d+).db_content/).last.first.to_i + 1
    query.mods[:sort] = "c#{sort}.db_content"
  end
end

# return value based on the (unproven) theory above
def shift_sort_table? query
  return unless (sort_statement = query.statement[:sort])
  sort_statement.is_a?(Hash) && sort_statement.size > 1
end

def add_sort_wql wql, sort_by
  if sort_by == "name"
    wql[:sort] = "name"
  else
    wql.merge! sort:  {
                  right: (sort_by || default_sort_by_key),
                  right_plus: "*cached count"
               },
               sort_as: "integer",
               dir: "desc"
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

  view :filter_form, cache: :never do
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
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = @paging_path_args.merge card.filter_hash
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
    wrap_with :a, toggle_text,
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
end
