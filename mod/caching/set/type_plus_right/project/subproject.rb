# subprojects tagged with this project (=left) via <project>+parent
include_set Abstract::SearchCachedCount

# does not quite fit the Abstract::TaggedByCachedCount pattern, because the cached
# count is on project+subproject, not project+project

recount_trigger :type_plus_right, :project, :parent do |changed_card|
  Abstract::CachedCount.pointer_card_changed_card_names(changed_card).map do |item_name|
    Card.fetch item_name.to_name.trait :subproject
  end
end

define_method :wql_hash do
  { type_id: Card::ProjectID, right_plus: [Card::ParentID, { refer_to: left.id }] }
end
