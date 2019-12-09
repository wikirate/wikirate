class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
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
        multi_metric { bookmark_wql :metric_id, value }
        multi_company { bookmark_wql :company_id, value }
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

      def bookmark_wql field, value
        return unless (restriction = Bookmark.id_restriction(value == :bookmark))

        restrict_to_ids field, restriction
      end
    end
  end
end
