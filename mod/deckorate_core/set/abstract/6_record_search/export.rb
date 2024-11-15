include_set Abstract::Export
include_set Abstract::DetailedExport

EXPORT_TYPES = {
  Records: :record,
  Companies: :company,
  Metrics: :metric
}.freeze

# supplementary search methods to be used in export formats
# (filtered search has different changes for html format...)
module ExportSearch
  def search_with_params
    if export_type == :record
      super
    else
      export_relation.pluck(export_id_field).map(&:card)
    end
  end

  def export_type
    @export_type ||= params[:type]&.to_sym || :record
  end

  def count_with_params
    if export_type == :record
      super
    else
      export_relation(count_query).count
    end
  end

  private

  def export_relation query=nil
    if export_type == :record
      lookup_relation
    else
      clean_relation(query).select(export_id_field).distinct.reorder export_id_field
    end
  end

  def export_id_field
    @export_id_field ||= export_type == :metric ? :metric_id : :company_id
  end
end

format :json do
  include ExportSearch

  view :compact, cache: :never do
    each_record_with_hash do |record, hash|
      hash[:companies][record.company_id] ||= record.company_name
      hash[:metrics][record.metric_id] ||= record.metric_name
      hash[:records][record.record.flex_id] ||= record.record.compact_json
    end
  end

  view :company_list, cache: :never do
    list_of_hashes = map_unique(:company_id) { |id| { id: id, name: id.cardname } }
    list_of_hashes.sort_by { |h| h[:name] }
  end

  view :metric_list, cache: :never do
    map_unique :metric_id, :metric_type_id do |id, type_id|
      { id: id, name: id.card.metric_title, metric_type: type_id.cardname }
    end
  end

  view :record_list, cache: :never do
    lookup_relation.map(&:compact_json)
  end

  view :keyed_record_list, cache: :never do
    lookup_relation.map { |a| a.compact_json.merge key: a.name.url_key }
  end

  view :type_lists, cache: :never do
    {
      companies: render_company_list,
      metrics: render_metric_list,
      records: render_record_list
    }
  end

  view :metric_type_counts, cache: :never do
    grouped_counts :metric_type_id
  end

  view :value_type_counts, cache: :never do
    grouped_counts :value_type_id
  end

  view :verification_counts, cache: :never do
    grouped_counts :verification
  end

  view :route_counts, cache: :never do
    grouped_counts :route
  end

  def grouped_counts subgroup
    lookup_query.joins(:metric).group(:year, subgroup).count.map do |array, count|
      { count: count, year: array.first, subgroup: array.last }
    end
  end

  def record_array hash
    hash[:records] = hash[:records].each_with_object([]) do |(key, val), array|
      array << val.merge(id: key)
    end
  end

  def each_record_with_hash
    search_with_params.each_with_object(
      companies: {}, metrics: {}, records: {}
    ) do |record, hash|
      yield record, hash
    end
  end

  def map_unique *fields
    lookup_query.joins(:metric).distinct.limit(1000).pluck(*fields).map do |result|
      yield result
    end
  end
end

format :csv do
  include ExportSearch

  view :titles do
    case export_type
    when :record
      Record.csv_titles detailed?
    else
      nest export_type, view: :titles
    end
  end

  view :body do
    if export_type == :record
      detailed = detailed?
      lookup_relation.map { |row| row.csv_line detailed }
    else
      super()
    end
  end
end

format :html do
  def export_types
    EXPORT_TYPES
  end

  def export_item_limit_label
    "Items"
  end
end
