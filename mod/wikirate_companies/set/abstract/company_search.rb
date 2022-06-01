include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::DeckorateFiltering
include_set Abstract::BookmarkFiltering
include_set Abstract::CommonFilters

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

def filter_class
  CompanyFilterQuery
end

format do
  delegate :filter_class, to: :card

  def filter_map
    shared_company_filter_map.unshift key: :name, open: true
  end

  def shared_company_filter_map
    %i[company_category company_group country] << { key: :company_answer, open: true }
  end

  def default_sort_option
    "id"
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Answers": :answer, "Most Metrics": :metric }.merge super
  end
end

format :html do
  def default_sort_option
    "answer"
  end

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + dataset_quick_filters
  end

  def filter_company_answer_type
    :company_answer_custom
  end

  def filter_company_answer_label
    "Advanced"
  end

  def company_answer_custom_filter _field, _default, _opts
    editor_wrap :content do
      subformat(card.field(:specification)).constraint_list_input
    end
  end

  def filter_company_answer_closer_value constraints
    Array.wrap(constraints).map do |c|
      bits = closer_constraint_bits c[:metric_id].to_i, c[:value], c[:group], c[:year]
      bits.compact.join " "
    end.join ", "
  end

  private

  def closer_constraint_bits metric_id, value, group, year
    [
      metric_id.card&.metric_title,
      "—",
      (value.present? && filter_value_closer_value(value)),
      (group.present? && group),
      (year.present? && "(#{year})")
    ]
  end
end

Abstract::AnswerSearch.include_set CompanySearch
