class Card
  class AnswerQuery
    # filters based on year and children of the answer card
    # (as opposed to metric and company)
    module AnswerFilters
      def filter_by_updated value
        return unless (period = timeperiod value)

        filter :updated_at, Time.now - period, ">"
      end

      def filter_by_year value
        return unless value.present?

        value = Array.wrap value
        if value.size == 1 && value.first.to_sym == :latest
          filter :latest, true
        else
          filter :year, value.map(&:to_i)
        end
      end

      def filter_by_verification value
        standard_verification_query(value) || non_standard_verification_query(value)
      end

      def checked_by whom
        restrict_by_cql :checked_by, :answer_id,
                        type_id: MetricAnswerID,
                        right_plus: [CheckedByID, { refer_to: whom }]
      end

      def filter_by_updater value
        # I attempted to do this with AR syntax and got close, but it wouldn't do all the
        # string substitutions, so the SQL had ?'s in it.
        #
        # Card.joins(actions: :act).where(
        #   "card_acts.actor_id" => whom.card_id,
        #   left_id: "answers.id",
        #   right_id: Card::ValueID
        # ).arel.exists.to_sql
        add_condition "EXISTS (select * from cards c " \
                        "JOIN card_actions an on an.card_id = c.id " \
                        "JOIN card_acts a on an.card_act_id = a.id " \
                        "WHERE a.actor_id in (?) " \
                        "AND c.right_id = #{Card::ValueID} " \
                        "AND c.left_id = answers.answer_id) ",
                      updater_ids(value)
      end

      def filter_by_calculated value
        @conditions << calculated_condition(value.to_sym != :calculated)
      end

      def filter_by_source value
        restrict_by_cql :source, :answer_id,
                        right: :source, refer_to: value, return: :left_id
      end

      private

      def filter_by_standard_verification value
        return unless (index = Answer.verification_index value)

        filter :verification, index
      end

      def filter_by_non_standard_verification value
        case value
        when "current_user"
          checked_by Auth.current_id
        when "wikirate_team"
          checked_by id: Set::Self::Steward.always_ids.unshift(:in)
        else
          raise Error::UserError, "unknown verification level: #{value}"
        end
      end

      def updater_ids value
        case value
        when "current_user"
          Auth.current_id
        when "wikirate_team"
          Set::Self::WikirateTeam.member_ids
        else
          value.card_id
        end
      end

      def calculated_condition negate
        "answer_id IS #{'NOT ' if negate}NULL"
      end

      def timeperiod value
        case value.to_sym
        when :today then
          1.day
        when :week then
          1.week
        when :month then
          1.month
        end
      end
    end
  end
end
