def add_id new_id
  add_item ("~#{new_id}")
end

def drop_id id
  drop_item  ("~#{id}")
end
