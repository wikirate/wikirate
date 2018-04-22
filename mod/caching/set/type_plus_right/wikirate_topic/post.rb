# cache # of posts tagged with this topic (=_left) via <post>+topic
include_set Abstract::TaggedByCachedCount, type_to_count: :post,
                                           tag_pointer: :wikirate_topic
