class Record
  # Methods to validate a new lookup entry
  module Validations
    def card_must_exist
      errors.add :record_id, "no card with id #{record_id}" unless card
    end

    def must_be_a_record
      return if card.type_id == Card::RecordID
      errors.add :record_id, "not a metric record: #{record_id.cardname}"
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
