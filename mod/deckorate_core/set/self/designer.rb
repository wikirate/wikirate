include_set Abstract::Search

def count
  ::Metric.select(:designer_id).distinct.count
end

def count_label
  "Metric designers"
end

