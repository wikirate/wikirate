# TODO: obviate all the following with a single rule setting

def default_type_id
  RecordLogID
end

include_set Type::RecordLog

def type_name
  :record_log.cardname
end

event :set_record_type, :prepare_to_store, on: :create do
  self.type_id = RecordLogID
end
