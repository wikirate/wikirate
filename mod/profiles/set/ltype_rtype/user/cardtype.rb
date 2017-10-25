# Set pattern: User+Cardtype
#
# used for the generation of contribution reports.
# Eg, Richard+Metrics is used to generate reports about Richard's metric-related
# contributions.
#
include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

ACTION_LABELS = {
  created: "Created", updated: "Updated",
  discussed: "Discussed", voted_on: "Voted On"
}.freeze

def user_card
  @user_card ||= left
end

def cardtype_card
  @cardtype_card ||= right
end

# returns [User]+[Cardtype]+report_search, a search card that finds cards
# for the given user/cardtype combination.
# See right/report_search for further information
def report_card variant
  @report_cards ||= {}
  @report_cards[variant] ||= begin
    rcard = Card.new name: name.trait(:report_search),
                     type_id: SearchTypeID
    # note: #new is important here, because we want different cards
    # for different variants
    rcard.variant = variant
    rcard
  end
end

def report_action_applies? action
  return true unless action == :voted_on
  # TODO: optimize by adding a test method on the cardtype card itself
  Card.new(type_id: cardtype_card.id).respond_to? :vote_count
end

format :html do
  view :contribution_report, tags: :unknown_ok, cache: :never do
    return "" unless show_contribution_report?
    class_up "card-slot", "contribution-report " \
                          "#{card.codename}-contribution-report"
    wrap { [contribution_report_header, contribution_report_body] }
  end

  def show_contribution_report?
    [:created, :updated, :discussed, :voted_on].find do |action|
      report_count(action) > 0
    end
  end

  def has_badges?
    card.cardtype_card.codename.to_sym.in? Abstract::BadgeSquad::BADGE_TYPES
  end

  def contribution_report_header
    wrap_with :div, class: "contribution-report-header" do
      [
        (contribution_report_title unless has_badges?),
        contribution_report_action_boxes
      ]
    end
  end

  def contribution_report_action_boxes
    wrap_with :ul, class: "nav nav-tabs" do
      contribution_report_action_boxes_list
    end
  end

  def contribution_report_action_boxes_list
    list = has_badges? ? [contribution_report_title_with_badges] : []
    list += [:created, :updated, :discussed, :voted_on].reverse.map do |report_action|
      if card.report_action_applies? report_action
        contribution_report_box report_action
      else
        contribution_null_box
      end
    end.unshift(contribution_report_toggle)
  end

  def contribution_report_title_with_badges
    #
    # wrap_with :li, class: "contribution-report-title-box" do
    #   wrap_with :a do
    #     [
    #       contribution_report_title,
    #       contribution_report_badges
    #     ]
    #   end
    # end
    content = contribution_report_title + contribution_report_badges
    wrap_with :li, class: "contribution-report-title-box" do
      link_to_view :contribution_report,
                   content,
                   path: { report_tab: :badges }, class: "slotter"
    end
  end

  def contribution_null_box
    wrap_with :li, class:  "contribution-report-box" do
      content_tag(:p, "")
    end
  end

  def contribution_report_box action, extra_class=nil
    active_tab = current_tab?(action) ? "active" : nil
    wrap_with :li, class: css_classes("contribution-report-box", extra_class, active_tab) do
      contribution_report_count_tab action
    end
  end

  def current_tab
    @current_tab ||= Env.params[:report_tab]
  end

  def current_tab? action
    action.to_s == current_tab
  end

  def contribution_report_count_tab action
    return "&nbsp;" unless card.report_action_applies? action
    link_to_view :contribution_report,
                 two_line_tab(ACTION_LABELS[action], report_count(action)),
                 path: { report_tab: action }, class: "slotter"
  end

  def report_count action
    @report_count ||= {}
    @report_count[action] ||= card.report_card(action).count
  end

  def contribution_report_title
    wrap_with :h4, class: "contribution-report-title" do
      card.cardtype_card.name.vary :plural
    end
  end

  def contribution_report_badges
    badges = card.field(:badges_earned, new: { type_id: PointerID })
    nest badges, view: :count
  end

  def contribution_report_badges_body
    return unless (badges = card.field(:badges_earned, new: {}))
    nest badges, view: :content
  end

  def contribution_report_toggle
    toggle_status = Env.params[:report_tab] ? :open : :closed
    wrap_with :li, class: "contribution-report-toggle text-center" do
      send "contribution_report_toggle_#{toggle_status}"
    end
  end

  def contribution_report_toggle_closed
    link_to_view :contribution_report, glyphicon("triangle-right"),
                 class: "slotter", path: { report_tab: :created }
  end

  def contribution_report_toggle_open
    link_to_view :contribution_report, glyphicon("triangle-bottom"),
                 class: "slotter"
  end

  def contribution_report_body
    return "" unless (action = current_tab)
    return contribution_report_badges_body if action.to_sym == :badges
    report_card = card.report_card action
    _render_contribution_list report_card: report_card
  end

  view :contribution_list, cache: :never do |args|
    report_card = args[:report_card]
    nest report_card, view: contribution_list_view,
                      structure: report_card.variant,
                      skip_perms: true
  end

  def contribution_list_view
    "#{card.right.codename}_list"
  end
end
