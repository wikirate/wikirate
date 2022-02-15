include_set Abstract::Certificate

def badge_count level=nil
  count = 0
  Card::BadgeSquad::BADGE_TYPES.each do |badge_type|
    next unless (badge_pointer = [self, badge_type, :badges_earned].card)
    count += badge_pointer.badge_count(level)
  end
  count
end
