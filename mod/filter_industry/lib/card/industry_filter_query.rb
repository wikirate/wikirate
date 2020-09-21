class Card
  module IndustryFilterQuery
    INDUSTRY_METRIC_NAME = "Global Reporting Initiative+Sector Industry"
    INDUSTRY_VALUE_YEAR = "2015"

    def industry_cql industry
      return unless industry.present?
      @filter_cql[:left_plus] <<
        self.class.industry_cql(industry)[:left_plus]
    end

    module ClassMethods
      def industry_cql industry
      {
        left_plus:
          [
            INDUSTRY_METRIC_NAME,
            {
              right_plus: [
                INDUSTRY_VALUE_YEAR,
                { right_plus: ["value", { eq: industry }] }
              ]
            }
          ]
      }
      end
    end
  end
end
