card_accessor :unpublished, type: :toggle

# TODO: this should work without explicit trash handling.
def unpublished
  return false if unpublished_card.trash

  unpublished_card.content == "1"
end

def unpublished?
  unpublished
end

def published?
  !unpublished?
end

def check_published
  return true unless unpublished? && !steward?

  deny_because "not yet published"
end

def ok_to_read?
  super && check_published
end
