# cache # of sources tagged with this topic (=left) via <source>+topic
include_set Abstract::ListRefCachedCount,
            type_to_count: :source,
            list_field: :topic
