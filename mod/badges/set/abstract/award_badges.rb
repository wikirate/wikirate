def award_badge_if_earned badge_type
  count = action_count badge_type
  return unless (badge = earns_badge(count, badge_type))
  award_badge fetch_badge_card(badge)
end

# @return badge name if count equals its threshold
def earns_badge count, action
  badge_hierarchy.earns_badge count, action
end

def award_badge badge_card
  name_parts = [Auth.current, badge_card.badge_type, :badges_earned]
  badge_pointer =
    subcard(name_parts) ||
      attach_subcard(Card.fetch(name_parts, new: { type_id: PointerID }))
  badge_pointer.add_badge badge_card.name
end

def fetch_badge_card badge_name
  badge_card = Card.fetch badge_name
  raise ArgumentError, "not a badge: #{badge_name}" unless badge_card
  badge_card
end

def action_count action, user=nil
  send "#{action}_count", user
end

