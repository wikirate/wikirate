# These Project+Company (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::Table

# @return [Card::Name]
def project_name
  name.left_name
end

# @return [Array] all of this card's items that refer to a valid company
def valid_company_cards
  @valid_company_cards ||=
    item_cards.sort_by(&:name).select do |company|
      company.type_id == WikirateCompanyID
    end
end

# @return [Array] a list of Company+Project cards (ltype rtype) that connect
# each of this card's company items to its project.
def all_company_project_cards
  valid_company_cards.map do |company|
    company_project_card company
  end
end

# @return [Card] a single Company+Project card (ltype rtype)
def company_project_card company_card
  Card.fetch company_card.name, project_name, new: {}
end

# are any of the metrics associated with this project researchable for this
# user?
# @return [True/False]
def any_researchable_metrics?
  Card.fetch([project_name, :metric]).item_cards.find do |metric_card|
    metric_card.user_can_answer?
  end
end

format :html do
  def editor
    :filtered_list
  end

  def default_item_view
    :listing
  end

  def filter_card
    Card.fetch :wikirate_company, :browse_company_filter
  end

  view :core do
    wrap_with :div, class: "progress-bar-table" do
      company_progress_table
    end
  end

  def company_progress_table
    wikirate_table(
      :company, card.all_company_project_cards,
      ok_columns([:company_thumbnail, :research_button, :research_progress_bar]),
      table: { class: "company-progress" },
      header: ok_columns(["Company", "", "Metrics Researched"]),
      td: { classes: ok_columns(%w[company-column button-column progress-column]) }
    )
  end

  # leave out middle column (research buttons) if no researchable_metrics
  def ok_columns columns
    return columns if card.any_researchable_metrics?
    [columns[0], columns[2]]
  end
end
