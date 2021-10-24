# cache # of posts tagged with this dataset (=left) via <post>+dataset
include_set Abstract::ListRefCachedCount,
            type_to_count: :post,
            list_field: :dataset
