event :update_relationship_lookup_table_due_to_value_change, :finalize, on: :update do
  update_relationship relationship_id: relationship_id
end

event :delete_relationship_lookup_table_entry_due_to_value_change, :finalize, on: :delete do
  delete_relationship relationship_id: relationship_id
end

# it's preferable to do this in finalize rather than integrate, but we don't always have
# the inverse_answer_id at this point.
event :create_relationship_lookup_entry_due_to_value_change, :integrate, on: :create do
  create_relationship relationship_id: relationship_id
end

def relationship_id
  left&.id || director.parent.card.id || left_id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
end
