class Card
  class CompanyFilterQuery < FilterQuery
    INDUSTRY_METRIC_NAME = "Global Reporting Initiative+Sector Industry"
    INDUSTRY_VALUE_YEAR = "2015"

    def company_wql company
      name_wql company
    end
    alias wikirate_company_wql company_wql

    def topic_wql value
      add_to_wql :found_by, value.to_name.trait_name(:wikirate_company).trait(:refers_to)
    end
    alias wikirate_topic_wql topic_wql

    def industry_wql industry
      return unless industry.present?
      @filter_wql[:left_plus] <<
        self.class.industry_wql(industry)[:left_plus]
    end

    def self.industry_wql industry
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
