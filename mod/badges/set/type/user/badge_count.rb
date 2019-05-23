include_set Abstract::Certificate

def badge_count level=nil
  count = 0
  Abstract::BadgeSquad::BADGE_TYPES.each do |badge_type|
    next unless (badge_pointer = field(badge_type, :badges_earned))
    count += badge_pointer.badge_count(level)
  end
  count
end
