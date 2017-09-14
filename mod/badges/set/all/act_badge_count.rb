def act_badge_count_step affinity_type, affinity_name
  act_badge_counts[affinity_type][affinity_name] += 1
end

def act_badge_count affinity_type, affinity_name
  act_badge_counts[affinity_type][affinity_name]
end

def act_badge_counts
  @act_badge_counts ||=
    Hash.new do |h1, k1|
      h1[k1] = Hash.new { |h2, k2| h2[k2] = 0 }
    end
end
