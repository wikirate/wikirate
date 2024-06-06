# cache # of projects organized by this research group (=left)
# via <research group>+researcher

# include_set Abstract::ProjectSearch
include_set Abstract::ListRefCachedCount,
            type_to_count: :project,
            list_field: :organizer
