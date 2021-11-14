class Answer
  # Methods to validate a new lookup entry
  module Validations
    def card_must_exist
      errors.add :answer_id, "no card with id #{answer_id}" unless card
    end

    def must_be_an_answer
      return if card.type_id == Card::MetricAnswerID
      errors.add :answer_id, "not a metric answer: #{Card.fetch_name answer_id}"
    end

    def metric_must_exist
      if (metric = metric_card)
        metric_error "is not a Metric" unless metric.type_id == Card::MetricID
      else
        metric_error "does not exist"
      end
    end

    def metric_error message
      errors.add :metric_id, "#{metric_id&.cardname} #{message}"
    end
  end
end
