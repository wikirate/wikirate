# cache # of datasets tagged with this company (=left) via <dataset>+company
include_set Abstract::TaggedByCachedCount,
            type_to_count: :dataset, tag_pointer: :wikirate_company

# def cql_content
#   super.merge prepend: name.left
# end
