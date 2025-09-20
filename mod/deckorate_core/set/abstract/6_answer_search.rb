include_set Abstract::BsBadge
include_set Abstract::Table
include_set Abstract::DeckorateFiltering
include_set Abstract::MetricSearch
include_set Abstract::LookupSearch
include_set Abstract::AnswerFilters
include_set Abstract::ProgressBar
include_set Abstract::JsonldSupported

def item_type_id
  AnswerID
end

def query_class
  AnswerQuery
end

format do
  def filter_map
    filtering_by_published do
      [:year,
       { key: :company_filters, type: :group, label: :company.cardname,
         filters: company_filters },
       { key: :metric_filters, type: :group, label: :metric.cardname,
         filters: metric_filters },
       { key: :answer, type: :group, label: "Data point",
         filters: answer_filters },
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

  def answer_filters
    [{ key: :value, open: true }] +
      %i[verification calculated status route updated updater source]
  end

  def metric_filters
    [
      { key: :metric, label: "Metric Name", open: true },
      :metric_keyword
    ] + shared_metric_filter_map
  end

  def company_filters
    [
      { key: :company, label: "Company Name", open: true },
      :company_keyword
    ] + shared_company_filter_map
  end

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
