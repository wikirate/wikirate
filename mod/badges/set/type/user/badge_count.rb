include_set Abstract::Certificate

def badge_count level=nil
  count = 0
  Abstract::BadgeSquad::BADGE_TYPES.each do |badge_type|
    next unless (badge_pointer = field(badge_type, :badges_earned))
    count += badge_pointer.badge_count(level)
  end
  count
end

format :html do
  delegate :badge_count, to: :card

  def header_right
    output [
      wrap_with(:h2, _render_title, class: "header-right"),
      wrap_badge
    ]
  end

  def wrap_badge
    wrap_with :div, class: "badges-earned" do
      content_tag :h3, medal_counts("horizontal")
    end
  end
end
