RSpec.describe Card::Set::Type::User do
  def card_subject
    Card["Joe Camel"]
  end

  check_views_for_errors :open_content, :edit,
                         :research_group_tab, :contributions_tab, :activity_tab
end
