card_accessor :unpublished

# TODO: this should work without explicit trash handling.
def unpublished
  return false if unpublished_card.trash

  unpublished_card.content == "1"
end
