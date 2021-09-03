# cache # of datasets tagged with this metrics (=left) via <dataset>+metric
include_set Abstract::TaggedByCachedCount,
            type_to_count: :dataset, tag_pointer: :metric

def cql_content
  super.merge prepend: name.left
end
