format :html do
  delegate :badge_level, :threshold, to: :card

  view :description do
    "Awarded for #{valued_action} #{humanized_threshold}."
  end

  view :level do
    wrap_with :div, class: "badge-certificate" do
      certificate
    end
  end

  view :badge do
    card.name
  end

  def certificate
    glyphicon :certificate, badge_level
  end

  def humanized_threshold
    if threshold == 1
      "your first #{valued_object}"
    else
      "#{threshold} #{valued_object.pluralize}"
    end
  end
end

def threshold
  @threshold ||= badge_class.threshold badge_action, affinity_type, badge_key
end

def badge_level
  @level ||= badge_class.level badge_action, affinity_type, badge_key
end

def badge_level_index
  @level_index ||= badge_class.level_index badge_action, affinity_type, badge_key
end

def affinity_type
  nil
end

def badge_key
  @badge_key ||= codename.to_sym
end

def badge_action
  raise StandardError, "badge_action not overridden"
end

def badge_type
  raise StandardError, "badge_class not overridden"
end

def badge_class
  @badge_class ||=
    Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeHierarchy"
end

def <=> other
  valid_to_compare? other
  action_order = compare_actions other
  return action_order unless action_order == 0
  compare_levels other
end

def compare_actions other
  actions = badge_class.badge_actions
  actions.index(badge_action) <=> actions.index(other.badge_action)
end

def compare_levels other
  if badge_level == other.badge_level
    affinity_type == :general ? 1 : -1
  else
    badge_level_index <=> other.badge_level_index
  end
end

def valid_to_compare? other
  unless other.respond_to? :badge_class
    raise ArgumentError, "comparison with non-badge card #{other} failed"
  end
  if badge_class != other.badge_class
    raise ArgumentError, "comparison of different badge types failed"
  end
  true
end

