class Card
  class FixedMetricAnswerQuery < AnswerQuery
    SIMPLE_FILTERS = ::Set.new([:metric_id, :latest, :year]).freeze
    LIKE_FILTERS = ::Set.new([:name]).freeze
    DB_COLUMN_MAP = { name: :company_name }.freeze
    # filter values are card names and have to be translated to card ids
    CARD_ID_FILTERS = ::Set.new().freeze

    def self.default metric_id
      MetricAnswer.fetch metric_id: metric_id, latest: true
    end

    def initialize metric_id, *args
      @metric_card = Card.fetch metric_id
      super *args

    end

    def prepare_filter_args filter
      super
      @filter_args[:metric_id] = @metric_card.id
    end

    def prepare_sort_args sort
      super
      if @sort_args[:sort_by].to_sym == :value && @metric_card.numeric?
        @sort_args[:cast] = "decimal(20,10)"
      end
    end

    def project_query value
      company_ids = Card.search(
        referred_to_by: "#{value}+#{Card.fetch_name :wikirate_company}",
        return: :id
      )
      @restrict_to_ids[:company_id] += company_ids
    end

    def industry_query value
      company_ids =
        Card.search CompanyFilterQuery.industry_wql(value).merge(return: :id)
      @restrict_to_ids[:company_id] += company_ids
    end

    def missing_answers
      FixedMetricMissingAnswerQuery.new(@filter_args).run
    end
  end
end
