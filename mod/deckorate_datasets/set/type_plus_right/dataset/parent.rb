assign_type :pointer
include_set Abstract::List # TODO: confirm all existing are pointers and remove

def ok_item_types
  :dataset
end
