class Card
  class AnswerQuery
    # Handle the where clause in answer queries
    module Where
      private

      # @return args for AR's where method
      def answer_conditions
        condition_sql([@conditions.join(" AND ")] + @values)
      end

      def condition_sql conditions
        ::Answer.sanitize_sql_for_conditions conditions
      end
    end
  end
end
