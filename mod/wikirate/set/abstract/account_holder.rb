# do not delete metrics when deleting account
def closure_deletions
  Card::Auth.as_bot do
    Card.search left: id, not: { any: { type: :metric, right: :account } }
  end
end
