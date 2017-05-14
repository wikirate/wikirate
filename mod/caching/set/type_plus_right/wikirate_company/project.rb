# cache # of projects tagged with this company (=left) via <project>+company
include_set Abstract::TaggedByCachedCount, type_to_count: :project,
                                           tag_pointer: :wikirate_company
