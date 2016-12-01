include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout

ACTION_LABELS = {
  created: "Created", updated: "Updated",
  discussed: "Discussed", voted_on: "Voted On"
}.freeze

def user_card
  @user_card ||= left
end

def cont_type_card
  @cont_type_card ||= right
end

def report_action_applies? action
  return true unless action == :voted_on
  # probably a faster way?
  Card.new(type_id: cont_type_card.id).respond_to? :vote_count
end

def report_card action
  @report_cards ||= {}
  @report_cards[action] ||= begin
    rcard = Card.new name: "#{name}+#{Card[:report_search].name}"
    rcard.variant = action
    rcard
  end
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

  def contribution_report_header
    wrap_with :div, class: "contribution-report-header" do
      [
        contribution_report_title,
        contribution_report_action_boxes
      ]
    end
  end

  def contribution_report_action_boxes
    wrap_with :ul, class: "nav nav-tabs" do
      [:created, :updated, :discussed, :voted_on].map do |report_action|
        contribution_report_box report_action
      end << contribution_report_toggle
    end
  end

  def contribution_report_box action
    wrap_with :li, class: "contribution-report-box" do
      contribution_report_count_tab action
    end
  end

  def contribution_report_count_tab action
    return "" unless card.report_action_applies? action
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
      card.cont_type_card.cardname.vary :plural
    end
  end

  def contribution_report_toggle
    toggle_status = Env.params[:report_tab] ? :open : :closed
    wrap_with :li do
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
    return "" unless (action = Env.params[:report_tab])
    report_card = card.report_card action
    item_view = card.cont_type_card.contribution_listing_view
    nest report_card, view: :content, structure: action, skip_perms: true,
                      items: { view: item_view }
  end
end
