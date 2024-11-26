class Answer
  # Methods to handle answers that exist only in the the answers table
  # and don't have a card. Used for calculated answer.
  module CardlessAnswers
    def card_without_answer_id name=nil, val=nil
      fetch_answer_card(name).tap do |card|
        if card.id
          update! answer_id: card.id
        else
          virtualize card, val
        end
      end
    end

    # true if there is no card for this answer
    def virtual?
      card&.virtual?
    end

    private

    def fetch_answer_card name=nil
      name ||= answer_name_from_parts
      Card.fetch name, eager_cache: true, new: { type_id: Card::AnswerID }
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
        card.define_singleton_method(:value_card) { virtual_value_card val }
        card.answer = self
      end
    end
  end
end
