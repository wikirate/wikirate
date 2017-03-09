BADGE_TYPES = [:metric, :project, :metric_value, :source, :wikirate_company]

def badge_count level=nil
  BADGE_TYPES.each_with_object(0) do |badge_type, count|
    next unless (badge_pointer = field(badge_type, :badges_earned))
    count += badge_pointer.badge_count level
  end
end
