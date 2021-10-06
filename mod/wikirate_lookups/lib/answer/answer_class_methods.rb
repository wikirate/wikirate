class Answer
  VERIFICATION_LEVELS = [
    { name: :flagged, icon: :flag,
      title: "Flagged" },
    { name: :community_added, klass: :community,
      title: "Unverified - Added by Community" },
    { name: :steward_added, klass: :steward,
      title: "Unverified - Added by Steward" },
    { name: :community_verified, klass: :community, icon: "check-circle",
      title: "Verified by Community" },
    { name: :steward_verified, klass: :steward, icon: "check-circle",
      title: "Verified by Steward" }
  ].freeze

  UNKNOWN = "Unknown".freeze

  # class methods for the Answer (lookup) constant
  module AnswerClassMethods
    include Export::ClassMethods

    VALUE_JOINT = Card::Set::Abstract::Value::JOINT

    # param retrn [Symbol] AR return argument(:count, :company_id, etc)
    # @param opts [Hash] search options
    # If the :where option is used then its value is passed as argument list to AR's where
    # method. Otherwise all remaining values besides `return` and `uniq` are
    # passed as hash to `where`.
    # @option opts [Hash] :where
    # @return answer card objects
    def search retrn, opts={}
      uniq = opts.delete :uniq
      where(opts.delete(:where) || opts)
        .uniq_select(uniq, retrn)
        .where("unpublished is not true")
        .return retrn
    end

    # @return [Answer]
    def fetch cardish
      for_card(cardish) || new_researched(cardish) || virtual(cardish) || new
    end

    # @return [True/False]
    def unknown? val
      val.to_s.casecmp("unknown").zero?
    end

    # @return [BigDecimal, nil]
    # If a val is a valid number return BigDecimal, otherwise nil.
    def to_numeric val
      Answer.unknown?(val) || !val.number? ? nil : val.to_d
    end

    # convert value format to lookup-table-suitable value
    # @return nil or String
    def value_to_lookup value
      return nil unless value.present?
      value.is_a?(Array) ? value.join(VALUE_JOINT) : value.to_s
    end

    # convert value from lookup table to
    def value_from_lookup string, type
      type == :multi_category ? string.split(VALUE_JOINT) : string
    end

    # @param [Symbol, String] name
    # @return [Integer] matching given verification level name
    #  (:flagged -> 0, :unverified -> 1, ...)
    def verification_index name
      name = name.to_sym
      VERIFICATION_LEVELS.index { |v| v[:name] == name }
    end

    private

    def new_researched cardish
      return unless (card_id = Card.id cardish)

      new_for_card(card_id).tap(&:refresh_fields)
    end

    def virtual cardish
      return unless (virtual_query = Card.cardish(cardish)&.virtual_query)

      where(virtual_query).take
    end
  end
end
