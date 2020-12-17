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

    def calculated_answer metric_card, company, year, value
      @card = card_without_answer_id metric_card.answer_name_for(company, year), value
      refresh
      @card.expire
      update_cached_counts
      self
    end

    def update_cached_counts
      (simple_cache_count_cards + topic_cache_count_cards).each(&:update_cached_count)
    end

    def simple_cache_count_cards
      [[metric_id, :metric_answer],
       [metric_id, :wikirate_company],
       [company_id, :metric],
       [company_id, :metric_answer],
       [company_id, :wikirate_topic]].map do |mark|
        Card.fetch(mark)
      end
    end

    def topic_cache_count_cards
      Card::Set::TypePlusRight::WikirateTopic::WikirateCompany
        .company_cache_cards_for_topics Card[metric_id]&.wikirate_topic_card&.item_names
    end

    def update_value value
      update! value_attributes(value)
    end

    def value_attributes value
      {
        value: value,
        numeric_value: to_numeric_value(value),
        updated_at: Time.now,
        editor_id: Card::Auth.current_id,
        calculating: false
      }
    end

    def restore_overridden_value
      calculated_answer metric_card, company, year, overridden_value
    end

    # class methods for {Answer} to support creating and updating calculated answers
    module ClassMethods
      def virtual_value name, val, value_type_code, value_cardtype_code
        Card.fetch [name, :value],
                   eager_cache: true,
                   new: { content: ::Answer.value_from_lookup(val, value_type_code),
                          type_code: value_cardtype_code }
      end

      def create_calculated_answer metric_card, company, year, value
        Answer.new.calculated_answer metric_card, company, year, value
      end
    end
  end
end
