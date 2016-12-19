# use for the filters on the "browse ..." pages

include_set Abstract::Filter
include_set Type::SearchType

def sort?
  true
end

def default_sort_by_key
  "metric"
end

def filter_keys
  %w(metric designer wikirate_topic project year)
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

def wql_hash
  wql = filter_wql
  wql[:limit] = 20
  add_sort_wql wql, sort_param if sort?
  wql
end

# the default search will take the first table in the join
# I need to override to shift the sort table to the next one
def search args={}
  query = fetch_query args
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
# want to sort by the result of the second statement
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

format do
  def extra_paging_path_args
    { filter: filter_hash }.merge sort_hash
  end
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
