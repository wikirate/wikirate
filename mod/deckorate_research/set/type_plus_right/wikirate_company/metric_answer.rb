# Answer search for a given Company
include_set Abstract::BookmarkFiltering
include_set Abstract::CachedCount
include_set Abstract::FixedAnswerSearch

# TODO: move this elsewhere. sdg is wikirate-specific
include_set Abstract::SdgFiltering


# recount number of answers for a given metric when an answer card is
# created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  changed_card.company_card&.fetch :metric_answer
end
# TODO: trigger recount from virtual answer batches

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    changed_card.left.company_card.fetch :metric_answer
  end
end

def fixed_field
  :company_id
end

def partner
  :metric
end

def bookmark_type
  :metric
end

format do
  def default_sort_option
    record? || !single?(:year) ? :year : :metric_bookmarkers
  end

  def secondary_sort_hash
    super.merge year: { metric_bookmarkers: :desc, metric_title: :asc }
  end

  def filter_map
    map_without_key super, :wikirate_company
  end

  def default_filter_hash
    { metric_name: "" }
  end
end

format :html do
  def cell_views
    [:metric_thumbnail_with_bookmark, :concise]
  end

  def header_cells
    [metric_sort_links, answer_sort_links]
  end

  def details_view
    :metric_details_sidebar
  end

  def quick_filter_list
    @quick_filter_list ||= :metric.card.format.quick_filter_list
  end

  def show_company_count?
    false
  end
end
