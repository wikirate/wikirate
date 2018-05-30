class Answer
  # Methods to validate a new lookup entry
  module Validations
    def card_must_exist
      return if card
      errors.add :answer_id, "no card with id #{answer_id}"
    end

    def must_be_an_answer
      return if card.type_id.in? [Card::MetricAnswerID, Card::RelationshipAnswerID]
      errors.add :answer_id, "not a metric answer: #{Card.fetch_name answer_id}"
    end

    def metric_must_exit
      unless metric_card
        errors.add :metric_id, "#{fetch_metric_name} does not exist"
        return
      end
      return if metric_card.type_id == Card::MetricID
      errors.add :metric_id, "#{fetch_metric_name} is not a metric"
    end
  end
end
