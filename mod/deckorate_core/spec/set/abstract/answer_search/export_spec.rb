RSpec.describe Card::Set::Abstract::AnswerSearch::Export do
  def card_subject
    :metric_answer.card
  end

  check_views_for_errors format: :json
end
