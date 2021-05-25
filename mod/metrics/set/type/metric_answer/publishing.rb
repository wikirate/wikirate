card_accessor :unpublished

# TODO: this should work without explicit trash handling.
def unpublished
  if researched_value?
    researched_unpublished
  elsif relationship?
    false
  else
    calculated_unpublished
  end
end

def researched_unpublished
  return false if unpublished_card.trash

  unpublished_card.content == "1"
end

# this answer is calculated
def calculated_unpublished
  dependee_answers.find(&:unpublished).present?
end
