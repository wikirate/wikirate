# cache # of claims tagged with this topic (=_left) via
include_set Abstract::TaggedByCachedCount, type_to_count: :claim,
                                           tag_pointer: :wikirate_topic
