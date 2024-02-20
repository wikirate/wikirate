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

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  changed_card.left.company_card.fetch :metric_answer
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  changed_card.left.company_card.fetch :metric_answer
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
    filter_map_without_keys super, :wikirate_company
  end

  def default_filter_hash
    { metric_name: "" }
  end

  def sort_options
    super.reject { |_k, v| v == :company_name }
  end
end

format :html do
  before :core do
    voo.items[:hide] = :company_thumbnail
  end

  def quick_filter_list
    @quick_filter_list ||= :metric.card.format.quick_filter_list
  end

  def show_company_count?
    false
  end
end
