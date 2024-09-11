# cache # of datasets tagged with this topic (=_left) via <dataset>+topic

include_set Abstract::ResearchGroupSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :research_group, list_field: :topic
