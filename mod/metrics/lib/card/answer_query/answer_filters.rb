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
        case value
        when (index = Answer.verification_index value)
          standard_verification_query index
        when "current_user"
          checked_by Auth.current_id
        when "wikirate_team"
          checked_by id: Set::Self::WikirateTeam.member_ids.unshift(:in)
        else
          raise User::Error, "unknown verification level: #{value}"
        end
      end

      def standard_verification_query index
        filter :verification, index
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

      def updater_ids value
        case value
        when "current_user"
          Auth.current_id
        when "wikirate_team"
          Set::Self::WikirateTeam.member_ids.join ", "
        else
          Card.fetch_id value
        end
      end

      def calculated_query value
        @conditions <<
          (value.to_sym == :calculated ? calculated_condition : not_calculated_condition)
      end

      def source_query value
        restrict_by_cql :answer_id,
                        type_id: Card::MetricAnswerID,
                        right_plus: [Card::SourceID, { refer_to: value }]
      end

      def related_company_group_query value
        company_id_field = "#{metric_card&.inverse? ? :subject : :object}_company_id"
        company_pointer_id = Card[value]&.wikirate_company_card&.id
        answer_ids = answer_ids_from_relationships company_id_field, company_pointer_id
        restrict_to_ids :answer_id, answer_ids
      end

      private

      def answer_ids_from_relationships company_id_field, referer_id
        answer_id_field = :"#{relationship_prefix}answer_id"
        relationship_relation(company_id_field, referer_id).distinct.pluck answer_id_field
      end

      # "relationship" in the wikirate sense. "relation" in the rails sense
      def relationship_relation company_id_field, referer_id
        Relationship.joins(
          "join card_references cr on cr.referee_id = relationships.#{company_id_field}"
        ).where(
          "cr.referer_id = #{referer_id} " \
          "and #{relationship_prefix}metric_id = #{metric_card.id}"
        )
      end

      def relationship_prefix
        @relationship_prefix ||= metric_card&.inverse? ? "inverse_" : ""
      end

      def calculated_condition
        "(metric_type_id IN #{CALCULATED_TYPE_IDS} AND answer_id IS NULL)"
      end

      def not_calculated_condition
        "(metric_type_id NOT IN #{CALCULATED_TYPE_IDS} OR answer_id IS NOT NULL)"
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
