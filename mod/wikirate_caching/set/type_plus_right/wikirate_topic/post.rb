# cache # of posts tagged with this topic (=_left) via <post>+topic
include_set Abstract::ListRefCachedCount,
            type_to_count: :post,
            list_field: :wikirate_topic
