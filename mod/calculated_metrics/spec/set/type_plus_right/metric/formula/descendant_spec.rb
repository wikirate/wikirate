RSpec.describe Card::Set::TypePlusRight::Metric::Formula::Descendant do
  def card_subject
    Card["Joe User+descendant 1+formula"]
  end

  check_html_views_for_errors
end
