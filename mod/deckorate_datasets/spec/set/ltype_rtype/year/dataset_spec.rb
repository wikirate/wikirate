RSpec.describe Card::Set::LtypeRtype::Year::Dataset do
  def card_subject
    Card.fetch ["1977", "Evil Dataset"], new: {}
  end

  check_views_for_errors
end
