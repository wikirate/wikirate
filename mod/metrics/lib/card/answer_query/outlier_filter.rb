class Card
  class AnswerQuery
    # filter for outliers
    module OutlierFilter
      def outliers_query value
        return unless single_metric?

        case value
        when "only"
          restrict_to_ids :id, outlier_ids
        when "exclude"
          filter :id, outlier_ids, "NOT IN" if outlier_ids.present?
        end
      end

      private

      def id_value_map
        @id_value_map ||=
          all_numeric_values.each_with_object({}) { |(id, val), h| h[id] = val }
      end

      def all_numeric_values
        Answer.where(metric_id: @filter_args[:metric_id])
          .where.not(numeric_value: nil)
          .pluck :id, :numeric_value
      end

      def outlier_ids
        @outlier_ids ||= id_value_map.present? ? savanna_outliers(id_value_map).keys : []
      end

      def savanna_outliers id_value_map
        @outliers ||= Savanna::Outliers.get_outliers id_value_map, :all
      end

      # alternative method to determine outliers; not finished
      # def turkey_outliers
      #   res = []
      #   all_related_answers.map do |answer|
      #     next unless answer.numeric_value
      #     res << [answer.numeric_value, answer.id]
      #   end
      #   res.sort!
      #   return if res.size < 3
      #   quarter = res.size / 3
      #   _q1 = res[quarter]
      #   _q3 = res[-quarter]
      #   res
      # end
    end
  end
end
