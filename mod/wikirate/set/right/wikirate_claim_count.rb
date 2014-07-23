view :raw do |args|
  Card.claim_counts( card.left.key ).to_s
end