include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def filter_keys
  %i[name project company_group bookmark]
end

def filter_class
  CompanyFilterQuery
end

def default_sort_option
  "answer"
end

def default_filter_hash
  { name: "" }
end

def bookmark_type
  :wikirate_company
end

def target_type_id
  Card::WikirateCompanyID
end

format :html do
  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + project_quick_filters
  end

  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric }.merge super
  end
end
