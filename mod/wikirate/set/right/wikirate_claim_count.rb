view :raw do |_args|
  Card.claim_counts(card.left.key).to_s
end
