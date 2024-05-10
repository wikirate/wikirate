include_set Abstract::BsBadge
include_set Abstract::Table
include_set Abstract::DeckorateFiltering
include_set Abstract::MetricSearch
include_set Abstract::LookupSearch
include_set Abstract::AnswerFilters
include_set Abstract::ProgressBar

def item_type_id
  MetricAnswerID
end

def query_class
  AnswerQuery
end

format do
  def filter_map
    filtering_by_published do
      [:year,
       { key: :wikirate_company,
         type: :group,
         filters: shared_company_filter_map.unshift(:company_name) },
       { key: :metric,
         type: :group,
         open: true,
         filters: shared_metric_filter_map.unshift(:metric_name) },
       { key: :metric_answer,
         type: :group,
         filters: [{ key: :value, open: true }] +
           %i[verification calculated status updated updater source] },
       :dataset]
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

  # def default_limit
  #   Auth.signed_in? ? 5000 : 500
  # end

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
  view :titles do
    Answer.csv_titles detailed?
  end

  view :body do
    detailed = detailed?
    lookup_relation.map { |row| row.csv_line detailed }
  end
end
