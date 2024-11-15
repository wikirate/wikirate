RSpec.describe Card::Set::Abstract::RecordSearch::Export do
  def card_subject
    :record.card
  end

  check_views_for_errors format: :json
end
