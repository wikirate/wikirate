require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

def fix_children_names parent
  parent.children.each do |child|
    new_name = Card::Name[child.left_id, child.right_id]
    if child.name != new_name
      child.update_columns name: new_name.s, key: new_name.key
    end
    fix_children_names child
  end
end

Card.where("name <> convert(name using ASCII) and left_id is null").find_each do |card|
  fix_children_names card
end
