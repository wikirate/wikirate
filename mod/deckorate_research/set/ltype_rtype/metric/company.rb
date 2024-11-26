# TODO: obviate all the following with a single rule setting

def default_type_id
  RecordID
end

include_set Type::Record

def type_name
  :record.cardname
end

event :set_answer_type, :prepare_to_store, on: :create do
  self.type_id = RecordID
end
