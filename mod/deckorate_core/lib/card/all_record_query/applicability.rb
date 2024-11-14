class Card
  class AllRecordQuery
    # makes queries respect company group and year applicability restrictions on metrics
    module Applicability
      private

      def filter_applicability
        if partner == :company
          restrict_to_applicable_companies
          validate_year_restriction
        else
          # filter inapplicable metrics
          restrict_metrics_by_company_group
          restrict_metrics_by_year
        end
      end

      def restrict_to_applicable_companies
        return unless (ids = metric_card&.company_group_card&.company_ids).present?

        restrict_partner_ids ids
      end

      # if there are year filters and year applicability restrictions,
      # there must be at least one year in common to find a result.
      def validate_year_restriction
        return unless (filt_year = filtered_year) &&
                      (appl_years = applicable_years).present?

        @empty_result = true unless filt_year.in? appl_years
      end

      def restrict_metrics_by_company_group
        return unless (never_ids = company_card&.inapplicable_metric_ids).present?

        restrict_not_partners_ids never_ids
      end

      def restrict_metrics_by_year
        return unless (not_now_ids = year_card&.inapplicable_metric_ids).present?

        restrict_not_partners_ids not_now_ids
      end

      def applicable_years
        return unless partner == :company

        metric_card&.year_card&.item_names&.sort
      end

      def year_card
        year = filtered_year
        year && Card[year]
      end
    end
  end
end
