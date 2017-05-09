# use for the filters on the "browse ..." pages

include_set Type::SearchType
include_set Abstract::Filter

def sort?
  true
end

def default_sort_by_key
  "metric"
end

def filter_keys
  %w[metric designer wikirate_topic project year]
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
  @wql = begin
    wql = filter_wql
    wql[:limit] = 20
    add_sort_wql wql, sort_param if sort?
    wql
  end
end

def add_sort_wql wql, sort_by
  wql.merge!(
    if sort_by == "name"
      { sort: "name" }
    else
      cached_count_sort_wql(sort_by)
    end
  )
end

def cached_count_sort_wql sort_by
  { sort: { right: (sort_by || default_sort_by_key),
            item: "cached_count",
            return: "count" },
    sort_as: "integer",
    dir: "desc" }
end

def virtual?
  true
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
                      collapse_text_in: "Hide Advanced",
                      collapse_text_out: "Show Advanced" }
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
      <div id="collapseFilter" class="collapse #{'in' if filter_advanced_active?}">
        #{yield}
      </div>
    </div>
    HTML
  end
end
