# cache # of posts tagged with this project (=left) via <post>+project
include_set Abstract::TaggedByCachedCount, type_to_count: :post,
                                           tag_pointer: :project
