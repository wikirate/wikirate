# cache # of research_groups tagged with this researcher (=left)
# via <research group>+researcher

include_set Abstract::ResearchGroupSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :research_group,
            list_field: :organizer
