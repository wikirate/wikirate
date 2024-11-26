RSpec.describe Card::Set::Abstract::AnswerSearch::Export do
  def card_subject
    :answer.card
  end

  check_views_for_errors format: :json
end
