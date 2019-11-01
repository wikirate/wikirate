# cache # of research_groups tagged with this researcher (=left)
# via <research group>+researcher
include_set Abstract::TaggedByCachedCount, type_to_count: :research_group,
                                           tag_pointer: :organizer
