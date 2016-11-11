include_set Abstract::BrowseFilterForm

def filter_keys
  %w(claimed cited company topic)
end

def extra_filter_args
  super.merge{ limit: 15 }
end

def sort_by wql, sort_by
  if sort_by == "recent"
    wql[:sort] = "update"
  else
    wql.merge! sort: { "right" => "*vote count" }, sort_as: "integer",
               dir: "desc"
  end
end

format :html do
  def page_link_params
    [:sort, :cited, :claimed, :wikirate_company, :wikirate_topic]
  end

  def sort_options
    super.merge "Most Important" => "important",
                "Most Recent" => "recent"
  end

  def default_sort_option
    "important"
  end
end
