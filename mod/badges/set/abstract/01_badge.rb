include_set Abstract::Certificate
include Comparable

format :html do
  delegate :badge_level, :threshold, :awarded_to, :awarded_count, to: :card

  view :core do
    <<-HTML
      <h3>#{certificate(badge_level)} #{badge_level} badge</h3>
      #{_render_description}
      <h4>Awarded to #{awarded_count} users</h4>
      #{awarded_to_list}
    HTML
  end

  view :description do
    "Awarded for #{valued_action} #{humanized_threshold}."
  end

  view :level do
    wrap_with :div, class: "badge-certificate" do
      certificate(badge_level)
    end
  end

  view :name_with_certificate do
    "#{certificate(badge_level)} #{card.name}"
  end

  view :link_with_certificate do
    "#{certificate(badge_level)} #{_render_link}"
  end

  view :badge, unknown: true do
    wrap_with :strong, safe_name
  end

  view :notify do
    class_up "alert", "text-center"
    alert :success, true, false do
      [
        "<h4>#{_render! :name_with_certificate}</h4>",
        _render_description
      ]
    end
  end

  view :awarded do
    "#{humanized_number awarded_count} awarded"
  end

  def humanized_threshold
    if threshold == 1
      "your first #{valued_object}"
    else
      "#{threshold} #{valued_object.pluralize}"
    end
  end

  def awarded_to_list
    voo.show! :thumbnail_link
    user_list = awarded_to.map { |ca| nest(ca, view: :thumbnail) }
    list_group user_list
  end
end

def awarded_to
  Card.search right_plus: [:badges_earned, { refer_to: id }],
              return: "_left", sort_by: :name
end

def awarded_count
  Card.search right: :badges_earned, refer_to: id, return: :count
end

def flash_message
  format(:html)._render_notify
end

def threshold
  @threshold ||= badge_class.threshold badge_action, affinity_type, badge_key
end

def badge_level
  @level ||= badge_class.level badge_action, affinity_type, badge_key
end

def badge_level_index
  @level_index ||=
    badge_class.level_index badge_action, affinity_type, badge_key
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
    Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeSquad"
end

def <=> other
  valid_to_compare! other
  compare_levels(other) ||
    compare_actions(other) ||
    (affinity_type == :general ? 1 : -1)
end

def compare_actions other
  actions = badge_class.badge_actions
  action_order = actions.index(other.badge_action) <=> actions.index(badge_action)
  !action_order.zero? && action_order
end

def compare_levels other
  level_order = badge_level_index <=> other.badge_level_index
  !level_order.zero? && level_order
end

def valid_to_compare! other
  unless other.respond_to? :badge_class
    raise ArgumentError, "comparison with non-badge card #{other} failed"
  end
  if badge_class != other.badge_class
    raise ArgumentError, "comparison of different badge types failed"
  end
end
