RSpec.describe Card::Set::TypePlusRight::Metric::Formula::WikiRating do
  def card_subject
    Card["Jedi+darkness rating+formula"]
  end

  check_views_for_errors :rating_core, :rating_editor
end
