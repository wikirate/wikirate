# include_set Abstract::Search
# include_set Abstract::SearchViews

def count
  ::Metric.select(:designer_id).distinct.count
end

def count_label
  "Metric designers"
end

def designers_by_count
  ::Metric.connection.exec_query(
    "select designer_id, count(*) as count from metrics
     group by designer_id order by count desc"
  ).rows
end


# def search _args
#   designers_by_count.map do |designer_id, _count|
#     designer_id.card
#   end
# end

format :html do
  view :core, template: :haml
  #
  # def paging_needed?
  #   false
  # end
end

