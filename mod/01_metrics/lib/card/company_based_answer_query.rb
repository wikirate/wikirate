class Card
  class CompanyBasedAnswerQuery < MetricAnswerQuery
    SIMPLE_FILTERS = ::Set.new([:metric_id, :latest, :year]).freeze
    LIKE_FILTERS = ::Set.new([:name]).freeze

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
      company_ids =
        Card.search referred_to_by: { left: { name: value },
                                      right: { codename: "wikirate_company" } },
                    return: :id
      @restrict_to_ids[:company_id] += company_ids
    end

    def industry_query value
      company_ids =
        Card.search CompanyFilterQuery.industry_wql(value).merge(return: :id)
      @restrict_to_ids[:company_id] += company_ids
    end

    def exact_match_filters
      SIMPLE_FILTERS
    end

    def like_filters
      LIKE_FILTERS
    end

    def filter_key_to_db_column key
      key.to_sym == :name ? :company_name : key
    end


    def metric_value_query value
      case value.to_sym
      when :none
        missing_answers
      else
        if (period = timeperiod(value))
          filter :updated_at, Time.now - period, ">"
        end
      end
    end

    def missing_answers
      CompanyBasedMissingMetricAnswerQuery.new(@filter_args).run
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
