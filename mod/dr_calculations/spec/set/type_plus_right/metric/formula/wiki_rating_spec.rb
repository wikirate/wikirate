RSpec.describe Card::Set::TypePlusRight::Metric::Formula::WikiRating do
  def card_subject
    Card["Jedi+darkness rating+formula"]
  end

  check_html_views_for_errors
end
