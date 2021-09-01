# cache # of posts tagged with this dataset (=left) via <post>+dataset
include_set Abstract::TaggedByCachedCount, type_to_count: :post,
                                           tag_pointer: :dataset
