include_set Type::Record

event :set_record_type, :prepare_to_store, on: :create do
  self.type_id = Card::RecordID
end
