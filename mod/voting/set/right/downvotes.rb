# def add_item newname
#   claim = Card.fetch(newname) and super("~#{claim.id}")
#   #   if super and claim = Card.fetch(newname)
#   #     claim.add_downvote
#   #   end
# end
#
# def drop_item name
#   claim = Card.fetch(name) and super("~#{claim.id}")
#   #   if super and claim = Card.fetch(name)
#   #     claim.delete_downvote
#   #   end
# end

def add_id new_id
  add_item ("~#{new_id}")
end

def drop_id id
  drop_item  ("~#{id}")
end

