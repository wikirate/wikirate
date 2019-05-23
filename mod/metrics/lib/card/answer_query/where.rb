class Card
  class AnswerQuery
    module Where
      def where additional_filter={}
        Answer.where where_args(additional_filter)
      end

      private

      def set_temp_filter opts
        return unless opts.present?

        c = @conditions
        v = @values
        r = @restrict_to_ids
        @conditions = []
        @values = []
        @restrict_to_ids = {}

        add_filter opts
        @restrict_to_ids.each do |key, values|
          filter key, values
        end

        @temp_conditions = @conditions
        @temp_values = @values
        @temp_restrict_to_ids = @restrict_to_ids
        @conditions = c
        @values = v
        @restrict_to_ids = r
      end

      # @return args for AR's where method
      def where_args temp_filter_opts={}
        set_temp_filter temp_filter_opts
        @restrict_to_ids.each do |key, values|
          filter key, values
        end
        [(@conditions + @temp_conditions).join(" AND ")] + @values + @temp_values
      end
    end
  end
end
