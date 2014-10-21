# def add_item newname
#   claim = Card.fetch(newname) and super("~#{claim.id}")
#   # if claim = Card.fetch(newname) and super("~#{claim.id}") and
#   #   claim.add_upvote
#   # end
# end
#
# def drop_item name
#   claim = Card.fetch(name) and super("~#{claim.id}")
#  #  if claim = Card.fetch(name) and super("~#{claim.id}")
#  #   claim.delete_upvote
#  # end
# end


def add_id new_id
  add_item ("~#{new_id}")
end

def drop_id id
  drop_item  ("~#{id}")
end
