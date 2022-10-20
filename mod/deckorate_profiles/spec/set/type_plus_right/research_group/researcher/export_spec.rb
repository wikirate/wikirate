RSpec.describe Card::Set::TypePlusRight::ResearchGroup::Researcher::Export do
  def card_subject
    Card.fetch ["Jedi", :researcher]
  end

  check_views_for_errors format: :csv
  check_views_for_errors format: :json
end
