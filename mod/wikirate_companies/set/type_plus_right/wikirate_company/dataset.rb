# cache # of datasets tagged with this company (=left) via <dataset>+company
include_set Abstract::ListRefCachedCount,
            type_to_count: :dataset,
            list_field: :wikirate_company

# def cql_content
#   super.merge prepend: name.left
# end
