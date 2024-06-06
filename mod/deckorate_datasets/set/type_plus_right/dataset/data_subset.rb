# data_subsets tagged with this dataset (=left) via <dataset>+parent

include_set Abstract::DatasetSearch
include_set Abstract::SearchCachedCount

# does not quite fit the Abstract::ListRefCachedCount pattern, because the cached
# count is on dataset+data_subset, not dataset+dataset

recount_trigger :type_plus_right, :dataset, :parent do |changed_card|
  changed_card.changed_item_names.map do |item_name|
    Card.fetch item_name.to_name.field :data_subset
  end
end

define_method :cql_hash do
  { type_id: DatasetID, right_plus: [ParentID, { refer_to: left.id }] }
end

def virtual?
  new?
end

def cql_content
  { type: :dataset, right_plus: [:parent, { refer_to: "_left" }] }
end
