class Card
  class AnswerQuery
    # Handle the where clause in answer queries
    module Where
      def where additional_filter={}
        Answer.where where_args(additional_filter)
      end

      private

      # @return args for AR's where method
      def answer_conditions
        condition_sql([@conditions.join(" AND ")] + @values)
      end

      def card_conditions
        if @card_ids.present?
          @card_conditions << "#{@subject}.id IN (?)"
          @card_values << @card_ids
        end
        condition_sql([@card_conditions.join(" AND ")] + @card_values)
      end

      def condition_sql conditions
        ::Answer.sanitize_sql_for_conditions conditions
      end
    end
  end
end
