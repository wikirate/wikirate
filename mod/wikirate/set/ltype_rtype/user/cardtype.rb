
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
  @report_cards[action] ||= build_report_card(action)
end

def build_report_card action
  # tcard = cont_type_card
  # tmethod = "#{action}_report_type_id"
  # type_id = tcard.respond_to?(tmethod) ? tcard.send(tmethod) : SearchTypeID
  Card.new type_id: SearchTypeID,
           content: cont_type_card.send("#{action}_report_content",
                                        user_card.id)
end



format :html do
  view :contribution_report, tags: :unknown_ok, cache: :never do
    class_up "card-slot", "contribution-report " \
                          "#{card.codename}-contribution-report"
    wrap { [contribution_report_header, contribution_report_body] }
  end

  def contribution_report_header
    wrap_with :div, class: "contribution-report-header" do
      [
        contribution_report_title,
        contribution_report_action_boxes,
        contribution_report_toggle
      ]
    end
  end

  def contribution_report_action_boxes
    [:created, :updated, :discussed, :voted_on].map do |report_action|
      contribution_report_box report_action
    end
  end

  def contribution_report_box action
    wrap_with :div, class: "contribution-report-box" do
      contribution_report_count action
    end
  end

  def contribution_report_count action
    return "" unless card.report_action_applies? action
    [
      wrap_with(:label, card.report_card(action).count),
      wrap_with(:span, ACTION_LABELS[action])
    ]
  end

  def contribution_report_title
    wrap_with :h4, class: "contribution-report-title" do
      card.cont_type_card.cardname.vary :plural
    end
  end

  def contribution_report_toggle
    toggle_status = Env.params[:report_tab] ? :open : :closed
    send "contribution_report_toggle_#{toggle_status}"
  end

  def contribution_report_toggle_open
    link_to_view :contribution_report, "v", class: "slotter"
  end

  def contribution_report_toggle_closed
    link_to_view :contribution_report, ">", class: "slotter",
                                            path: { report_tab: :created }
  end

  def contribution_report_body
    return "" unless (action = Env.params[:report_tab])
    report_card = card.report_card action
    item_view = card.cont_type_card.contribution_listing_view
    nest report_card, view: :content,
                      items: { view: item_view },
                      skip_perms: true
  end
end
