include_set Abstract::CachedCount
include_set Abstract::MetricSearch
include_set Abstract::FeaturedBoxes
include_set Abstract::OpenSearch
include_set Abstract::ExportAll
include_set Abstract::FluidLayout

recount_trigger :type, :metric, on: [:create, :delete] do |_changed_card|
  Card[:metric]
end

def count
  MetricQuery.new({}).count
end

format :html do
  view :page, template: :haml, wrap: :slot

  def edit_fields
    %i[description featured]
  end

  # before(:filtered_content) { voo.items[:view] = :box }

  def featured_label
    @featured_label ||= :benchmark.cardname.vary(:plural).downcase
  end

  def featured_link_path
    path filter: { benchmark: "1" }
  end
end

format :json do
  def os_type_param
    :metric
  end

  def complete_or_match_search limit: 10
    return super if os_search?

    paging = { limit: limit }
    sort = { metric_title: :asc }
    query = term_param ? { metric_keyword: term_param } : {}
    MetricQuery.new(query, sort, paging).run
  end
end
