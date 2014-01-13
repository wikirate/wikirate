view :raw do |args|
  subject = card.left
  Card.claim_counts subject.key
end