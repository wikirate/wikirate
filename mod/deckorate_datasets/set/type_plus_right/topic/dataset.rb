# cache # of datasets tagged with this topic (=_left) via <dataset>+topic

include_set Abstract::DatasetSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :dataset,
            list_field: :topic
