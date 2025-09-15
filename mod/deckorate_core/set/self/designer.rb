include_set Abstract::Items

assign_type :search

def count
  ::Metric.select(:designer_id).distinct.count
end

def search _args={}
  ::Metric.select(:designer_id, "count(*) as count")
        .group(:designer_id)
        .order("count desc")
        .limit(limit).map do |m|
    m.designer_id.card
  end
end

def paging_params
  {}
end

def cql_hash
  {}
end

def limit
  10
end

format do
  delegate :limit, to: :card

  def filter_and_sort_cql
    {}
  end
end

# format :html do
#   view :core, template: :haml
# end
