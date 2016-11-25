
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

def standard_report_count args
  wql = { type_id: cont_type_card.id, return: :count }.merge args
  Card.search wql
end

def created_report_count
  standard_report_count created_by: user_card.id
end

def updated_report_count
  standard_report_count edited_by: user_card.id
end

def discussed_report_count
  standard_report_count right_plus: [Card::DiscussionID,
                                     { edited_by: user_card.id }]
end

def voted_on_report_count
  standard_report_count linked_to_by: {
    left_id: user_card.id, right_id: [:in, UpvotesID, DownvotesID]
  }
end

format :html do
  view :contribution_report, tags: :unknown_ok do
    wrap_with :div, class: "contribution-report " \
                           "#{card.codename}-contribution-report" do
      [contribution_report_header, contribution_report_body]
    end
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
      wrap_with(:label, card.send("#{action}_report_count")),
      wrap_with(:span, ACTION_LABELS[action])
    ]
  end

  def contribution_report_title
    wrap_with :h4, class: "contribution-report-title" do
      card.cont_type_card.cardname.vary :plural
    end
  end

  def contribution_report_toggle
    ">"
  end

  def contribution_report_body
  end
end
