# include with option :type_class
def self.included host_class
  host_class.class_eval do
    define_method :badge_squad do
      @badge_squad ||=
        Card::Set::Abstract::BadgeSquad.for_type host_class.squad_type
    end
  end
end

include ::NewRelic::Agent::MethodTracer

def award_badge_if_earned badge_type
  return unless awardable_act? && (badge = earns_badge(badge_type))
  award_badge fetch_badge_card(badge)
end

add_method_tracer :award_badge_if_earned, "award_badge_if_earned"

# don't award badges during imports or API calls
def awardable_act?
  !(import_act? || token_act?)
end

def token_act?
  Rails.env.production? && Card::Env.params[:token] && !Card::Auth.session_user
end

# @return badge name if count equals its threshold
def earns_badge action
  badge_squad.earns_badge action
end

def award_badge badge_card
  badge_pointer = current_badge_pointer badge_card
  badge_pointer.add_badge_card badge_card
  attach_subcard badge_pointer
end

def current_badge_pointer badge_card
  name_parts = [Auth.current, badge_card.badge_type, :badges_earned]
  badge_pointer = Card.fetch(name_parts, new: { type_id: PointerID })
  active_badge_pointer(badge_pointer) || badge_pointer
end

def active_badge_pointer badge_pointer
  return unless ActManager.include? badge_pointer.name
  director = ActManager.fetch(badge_pointer)
  director.reset_stage
  director.card
end

def fetch_badge_card badge_name
  badge_card = Card.fetch badge_name
  raise ArgumentError, "not a badge: #{badge_name}" unless badge_card
  badge_card
end

def action_count action, user=nil
  send "#{action}_count", user
end
