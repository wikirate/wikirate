class Card
  class AnswerQuery
    # filter for outliers
    module OutlierQuery
      def outliers_query
        restrict_to_ids :id, outlier_ids
      end

      private

      def id_value_map
        all_related_answers.each_with_object({}) do |answer, h|
          next unless answer.numeric_value
          h[answer.id] = answer.numeric_value
        end
      end

      def all_related_answers
        Answer.where(metric_id: @metric_id)
      end

      # alternative method to determine outliers; not finished
      def turkey_outliers
        res = []
        all_related_answers.map do |answer|
          next unless answer.numeric_value
          res << [answer.numeric_value, answer.id]
        end
        res.sort!
        return if res.size < 3
        quarter = res.size / 3
        _q1 = res[quarter]
        _q3 = res[-quarter]
        res
      end

      def outlier_ids
        return [] unless (value_map = id_value_map).present?
        savanna_outliers(value_map).keys
      end

      def savanna_outliers id_value_map
        @outliers ||= Savanna::Outliers.get_outliers id_value_map, :all
      end
    end
  end
end
