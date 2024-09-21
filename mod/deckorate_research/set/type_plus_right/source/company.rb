# TODO: make companies filterable on sources
# (The code below was breaking several specs)
#
# (see also mod/deckorate_graphql/lib/graph_q_l/types/source.rb)

# include_set Abstract::CompanySearch
# include_set Abstract::FilterableList

def ok_item_types
  :company
end
