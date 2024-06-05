# cache # of datasets tagged with this metrics (=left) via <dataset>+metric
include_set Abstract::DatasetSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :dataset,
            list_field: :metric

# def cql_content
#   super.merge prepend: name.left
# end
