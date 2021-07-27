RSpec.describe Card::Set::TypePlusRight::Metric::Formula::Categorical do
  def card_subject
    Card["Jedi+disturbances in the Force+Joe User+formula"]
  end

  check_html_views_for_errors
end
