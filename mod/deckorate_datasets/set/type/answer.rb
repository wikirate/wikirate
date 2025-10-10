card_reader :dataset, type: :pointer
# Genuinely don't understand why the above was needed. It was set to :search, which
# is not a type. Then it was set to :search_type, and many tests started breaking.
# I couldn't find a reason why it was needed, so I remove it, and again many things
# broke. Would be nice to be able to get rid of it.  Seems like nonsense.
