# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::TaggedByCachedCount, type_to_count: :metric,
                                           tag_pointer: :wikirate_topic
