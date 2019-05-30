# cache # of projects organized by this research group (=left)
# via <research group>+researcher
include_set Abstract::TaggedByCachedCount, type_to_count: :project,
            tag_pointer: :organizer
