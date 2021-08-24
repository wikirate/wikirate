class Answer
  # Methods to handle answers that exist only in the the answer table
  # and don't have a card. Used for calculated answers.
  module CardlessAnswers
    def self.included host_class
      host_class.extend ClassMethods
    end

    def card_without_answer_id name=nil, val=nil
      fetch_answer_card(name).tap do |card|
        if card.id
          update! answer_id: card.id
        else
          virtualize card, val
        end
      end
    end

    def fetch_answer_card name=nil
      name ||= answer_name_from_parts
      Card.fetch name, eager_cache: true,
                       new: { type_id: Card::MetricAnswerID }
    end

    def answer_name_from_parts
      [metric_id, company_id, year.to_s]
    end

    def virtualize vcard, val=nil
      val ||= value
      vcard.tap do |card|
        card.define_singleton_method(:virtual?) { true }
        card.define_singleton_method(:value) { val }
        # card.define_singleton_method(:updated_at) { updated_at }
        card.define_singleton_method(:value_card) do
          ::Answer.virtual_value name, val, value_type_code, value_cardtype_code
        end
      end
    end

    # true if there is no card for this answer
    def virtual?
      card&.virtual?
    end

    # class methods for {Answer} to support creating and updating calculated answers
    module ClassMethods
      def virtual_value name, val, value_type_code, value_cardtype_code
        Card.fetch [name, :value],
                   eager_cache: true,
                   new: { content: ::Answer.value_from_lookup(val, value_type_code),
                          type_code: value_cardtype_code }
      end

    end
  end
end
