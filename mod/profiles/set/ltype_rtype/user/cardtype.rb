# Set pattern: User+Cardtype
#
# used for the generation of contribution reports.
# Eg, Richard+Metrics is used to generate reports about Richard's metric-related
# contributions.
#
include_set Abstract::Header

card_reader :badges_earned, default: { type_id: Card::PointerID }

ACTION_LABELS = {
  created: "Created", updated: "Updated", discussed: "Discussed",
  voted_on: "Voted On", double_checked: "Checked"
}.freeze

ACTIONS = ACTION_LABELS.keys.freeze

def user_card
  @user_card ||= left
end

def cardtype_card
  @cardtype_card ||= right
end

def cardtype_codename
  cardtype_card.codename&.to_sym
end

# returns [User]+[Cardtype]+report_search, a search card that finds cards
# for the given user/cardtype combination.
# See right/report_search for further information
def report_card variant
  return if variant.blank?
  @report_cards ||= {}
  @report_cards[variant] ||= begin
    rcard = Card.new name: name.trait(:report_search), type_id: SearchTypeID
    # note: #new is important here, because we want different cards
    # for different variants
    rcard.variant = variant
    rcard
  end
end

def report_action_applies? action
  return true unless action.to_sym.in? %i[voted_on double_checked]
  # TODO: optimize by adding a test method on the cardtype card itself
  send "#{action}_applies?"
end

def voted_on_applies?
  Card.new(type_id: cardtype_card.id).respond_to? :vote_count
end

def double_checked_applies?
  cardtype_card.id == MetricAnswerID
end

format :html do
  delegate :report_card, :badges_earned_card, :report_action_applies?, :cardtype_codename,
           to: :card

  view :contribution_report, tags: :unknown_ok, cache: :never, template: :haml do
    class_up "card-slot", "contribution-report #{cardtype_codename}-contribution-report"
  end

  def show_contribution_report?
    valid_actions.any? { |action| report_count(action).positive? }
  end

  def valid_actions
    vars =  %i[created updated discussed]
    vars << (%i[voted_on double_checked].find { |a| report_action_applies? a })
    vars
  end

  def has_badges?
    cardtype_codename.in? Abstract::BadgeSquad::BADGE_TYPES
  end

  def report_title_link
    link_text = report_title + nest(badges_earned_card, view: :count)
    report_link link_text, :badges
  end

  def report_title
    wrap_with :h5, class: "contribution-report-title" do
      card.cardtype_card.try(:contribution_report_title) ||
        card.cardtype_card.name.vary(:plural)
    end
  end

  def current_tab
    @current_tab ||= Env.params[:report_tab]&.to_sym
  end

  def current_tab? action
    action == current_tab
  end

  def report_tab action
    two_line_tab ACTION_LABELS[action], report_count(action)
  end

  def report_link text, action, nav_link=false
    link_args = { class: report_link_classes(nav_link, action) }
    link_args[:path] = { report_tab: action } if action
    link_to_view :contribution_report, text, link_args
  end

  def report_link_classes nav_link, action
    klasses = ["slotter"]
    klasses << "nav-link" if nav_link
    klasses << "active" if current_tab? action
    css_classes klasses
  end

  def report_count action
    return 0 unless action
    @report_count ||= {}
    @report_count[action] ||= report_card(action).count
  end

  def toggle_icon
    current_tab ? fa_icon("chevron-down") : fa_icon("chevron-right")
  end

  def toggle_action
    :created unless current_tab
  end

  def contribution_list
    if current_tab? :badges
      nest badges_earned_card, view: :content
    elsif (rcard = report_card(current_tab))
      nest rcard, view: :list_with_subtabs, structure: rcard.variant, skip_perms: true
    end
  end
end
