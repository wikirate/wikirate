class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      include WikirateFilterQuery

      def industry_query value
        multi_company do
          restrict_by_wql :company_id, CompanyFilterQuery.industry_wql(value)
        end
      end

      def company_group_query value
        multi_company do
          restrict_by_wql :company_id,
                          referred_to_by: "#{value}+#{:wikirate_company.cardname}"
        end
      end

      def topic_query value
        multi_metric do
          restrict_by_wql :metric_id, right_plus: [WikirateTopicID, { refer_to: value }]
        end
      end
      alias wikirate_topic_query topic_query

      def project_query value
        multi_metric { project_restriction :metric_id, :metric, value }
        multi_company { project_restriction :company_id, :wikirate_company, value }
      end

      def project_restriction field, codename, value
        restrict_by_wql field, referred_to_by: "#{value}+#{codename.cardname}"
      end

      def bookmark_query value
        multi_metric do
          bookmark_wql value
        end
      end

      # SUPPORT METHODS
      def single_metric?
        @filter_args[:metric_id].is_a? Integer
      end

      def single_company?
        @filter_args[:company_id].is_a? Integer
      end

      def multi_metric
        single_metric? ? return : yield
      end

      def multi_company
        single_company? ? return : yield
      end

      def company_card
        single_company? ? (@company_card ||= Card[@filter_args[:company_id]]) : return
      end

      def metric_card
        single_metric? ? (@metric_card ||= Card[@filter_args[:metric_id]]) : return
      end

      def nonbookmarker_bookmark_wql value
        return unless value == :bookmark

        restrict_to_ids [] # no bookmark results for nonbookmarker
      end

      def bookmarker_bookmark_wql value
        bookmarked = { linked_to_by: bookmark_list_id }
        restrict_by_wql :metric_id,
                        (value == :bookmark ? bookmarked : { not: bookmarked })
      end
    end
  end
end
