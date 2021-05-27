class Card
  class AnswerQuery
    # filters based on year and children of the answer card
    # (as opposed to metric and company)
    module AnswerFilters
      CALCULATED_TYPE_IDS =
        "(#{[FormulaID, WikiRatingID, DescendantID, ScoreID].join ', '})".freeze

      def updated_query value
        return unless (period = timeperiod value)

        filter :updated_at, Time.now - period, ">"
      end

      def year_query value
        if value.try(:to_sym) == :latest
          filter :latest, true
        else
          filter :year, value.to_i
        end
      end

      def verification_query value
        standard_verification_query(value) || non_standard_verification_query(value)
      end

      def checked_by whom
        restrict_by_cql(:answer_id,
                        type_id: MetricAnswerID,
                        right_plus: [CheckedByID, { refer_to: whom }])
      end

      def updater_query value
        # I attempted to do this with AR syntax and got close, but it wouldn't do all the
        # string substitutions, so the SQL had ?'s in it.
        #
        # Card.joins(actions: :act).where(
        #   "card_acts.actor_id" => Card.fetch_id(whom),
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

      def calculated_query value
        @conditions << calculated_condition(value.to_sym == :calculated)
      end

      def source_query value
        restrict_by_cql :answer_id,
                        type_id: Card::MetricAnswerID,
                        right_plus: [Card::SourceID, { refer_to: value }]
      end

      # note: :false and "false" work; false doesn't (can't survive #process_filter)
      def published_query value
        return if value.to_s == "all" && stewards_all?
        @conditions <<
          case value.to_s
          when "true"
            published_condition
          when "false"
            unpublished_condition
          when "all"
            "(#{published_condition} OR (#{unpublished_condition}))"
          end
      end

      private

      # WikiRate team members are stewards of all metrics
      def stewards_all?
        Card::Auth.current.stewards_all?
      end

      def published_condition
        # handles nil and false
        "answers.unpublished is not true"
      end

      def unpublished_condition
        cond = "answers.unpublished is true"
        return cond if stewards_all?
        metric_ids = Card::Auth.current.stewarded_metric_ids
        if metric_ids.empty?
          @empty_results = true
        else
          "#{cond} and metric_id in (#{metric_ids.join ', '})"
        end
      end

      def standard_verification_query value
        return unless (index = Answer.verification_index value)

        filter :verification, index
      end

      def non_standard_verification_query value
        case value
        when "current_user"
          checked_by Auth.current_id
        when "wikirate_team"
          checked_by id: Set::Self::WikirateTeam.member_ids.unshift(:in)
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

      def calculated_condition positive=true
        nott = positive ? "" : "NOT "
        "(metric_type_id #{nott}IN #{CALCULATED_TYPE_IDS} AND answer_id IS #{nott}NULL)"
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
