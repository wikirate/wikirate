class Card
  class FixedMetricAnswerQuery < AnswerQuery
    SIMPLE_FILTERS = ::Set.new(%i[metric_id latest numeric_value]).freeze
    LIKE_FILTERS = ::Set.new(%i[name wikirate_company]).freeze
    DB_COLUMN_MAP = { name: :company_name,
                      wikirate_company: :company_name }.freeze
    # filter values are card names and have to be translated to card ids
    CARD_ID_FILTERS = ::Set.new.freeze

    def initialize metric_id, *args
      @metric_id = metric_id
      @metric_card = Card.fetch metric_id
      super *args
    end

    def prepare_filter_args filter
      super
      @filter_args[:metric_id] = @metric_id
    end

    def prepare_sort_args sort
      super
      return unless numeric_sort?
      @sort_args[:sort_by] = :numeric_value
    end

    def numeric_sort?
      @sort_args[:sort_by]&.to_sym == :value &&
        (@metric_card.numeric? || @metric_card.relationship?)
    end

    def project_query value
      company_ids = Card.search(
        referred_to_by: "#{value}+#{Card.fetch_name :wikirate_company}",
        return: :id
      )
      restrict_to_ids :company_id, company_ids
    end

    def industry_query value
      company_ids =
        Card.search CompanyFilterQuery.industry_wql(value).merge(return: :id)
      restrict_to_ids :company_id, company_ids
    end

    def missing_answer_query_class
      FixedMetricMissingAnswerQuery
    end

    def all_answer_query_class
      FixedMetricAllAnswerQuery
    end

    def outliers_query
      restrict_to_ids :id, outlier_ids
    end

    def value_query value
      super
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
