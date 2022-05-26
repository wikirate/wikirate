include_set Abstract::BsBadge
include_set Abstract::Table
include_set Abstract::DeckorateFiltering
include_set Abstract::MetricSearch
# include_set Abstract::BookmarkFiltering
include_set Abstract::LookupSearch
include_set Abstract::AnswerFilters

def item_type
  "Answer" # :metric_answer.cardname
end

def filter_class
  AnswerQuery
end

format do
  def filter_map
    filtering_by_published do
      [:year,
       { key: :metric,
         type: :group,
         open: true,
         filters: shared_metric_filter_map.unshift(key: :metric_name, open: true) },
       { key: :wikirate_company,
         type: :group,
         filters: [
           { key: :company_name, open: true },
           :company_category,
           :company_group
         ] },
       { key: :metric_answer,
         type: :group,
         filters: [{ key: :value, open: true }] +
           %i[verification calculated status updated updater source] },
       :dataset]
    end
  end

  def map_without_key map, key
    map.reject do |item|
      item_key = item.is_a?(Hash) ? item[:key] : item
      item_key == key
    end
  end

  def filter_hash_from_params
    super.tap do |h|
      normalize_filter_hash h if h
    end
  end

  def card_content_limit
    nil
  end

  def default_limit
    Auth.signed_in? ? 5000 : 500
  end

  private

  def normalize_filter_hash hash
    %i[metric company].each do |type|
      handle_exact_name hash, type
      handle_project_filter hash
    end
  end

  # names prefixed with an equals sign are treated as "exact" names
  def handle_exact_name hash, type
    key = :"#{type}_name"
    name = hash[key]
    return unless name&.match(/^=/)

    hash.delete key
    hash[:"#{type}_id"] = name.card_id
  end

  def handle_project_filter hash
    return unless (dataset = hash.delete :project)

    hash[:dataset] ||= dataset
  end
end

format :csv do
  view :core do
    Answer.csv_title + lookup_relation.map(&:csv_line).join
  end
end
