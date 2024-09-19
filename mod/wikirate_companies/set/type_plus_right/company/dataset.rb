# cache # of datasets tagged with this company (=left) via <dataset>+company
include_set Abstract::DatasetSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :dataset,
            list_field: :company
