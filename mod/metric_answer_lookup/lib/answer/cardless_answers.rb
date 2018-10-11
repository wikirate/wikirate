class Answer
  # Methods to handle answers that exist only in the the answer table
  # and don't have a card. Used for calculated answers.
  module CardlessAnswers
    def self.included host_class
      host_class.extend ClassMethods
    end

    def find_answer_card
      # for unknown reasons there are cases where `Card[record_name, year.to_s]` exists
      # for virtual answers. Fetching `Card[record_name, year.to_s, :value]` first,
      # ensures that we don't get a card when we don't want one.
      Card[record_name, year.to_s, :value]&.left
    end

    def virtual_answer_card name=nil, val=nil
      name ||= record_name ? [record_name, year.to_s] : [metric_id, company_id, year.to_s]
      val ||= value

      Card.fetch(name, new: { type_id: Card::MetricAnswerID }).tap do |card|
        card.define_singleton_method(:value) { val }
        # card.define_singleton_method(:updated_at) { updated_at }
        card.define_singleton_method(:value_card) do
          Card.new name: [name, :value],
                   content: ::Answer.value_from_lookup(val, value_type_code),
                   type_code: value_cardtype_code
        end
      end
    end

    # true if there is no card for this answer
    def virtual?
      card&.new_card?
    end

    def calculated_answer metric_card, company, year, value
      ensure_record metric_card, company
      @card = virtual_answer_card metric_card.metric_answer_name(company, year), value
      refresh
      update_cached_counts
      self
    end

    def update_cached_counts
      [[metric_id, :metric_answer],
       [metric_id, :wikirate_company],
       [company_id, :metric],
       [company_id, :metric_answer],
       [company_id, :wikirate_topic]].each do |mark|
        Card.fetch(mark).update_cached_count
      end
      Card::Set::TypePlusRight::WikirateTopic::WikirateCompany
        .topic_company_type_plus_right_cards_for_metric(Card[metric_id])
        .each(&:update_cached_count)
    end

    def update_value value
      update_attributes! value_attributes(value)
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
      def create_calculated_answer metric_card, company, year, value
        Answer.new.calculated_answer metric_card, company, year, value
      end

      # @param ids [Array<Integer>] ids of answers in the answer table (NOT card ids)
      def update_by_ids ids, *fields
        Array(ids).each do |id|
          next unless (answer = Answer.find_by_id(id))
          answer.refresh(*fields)
        end
      end
    end
  end
end
