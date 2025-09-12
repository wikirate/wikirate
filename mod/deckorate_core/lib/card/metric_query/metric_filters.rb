class Card
  class MetricQuery
    # metric-related filters (also used by AnswerQuery)
    module MetricFilters
      def filter_by_topic value
        restrict_by_cql(
          :topic, :metric_id,
          right: :topic, refer_to: ["in", value].flatten, return: :left_id
        )
      end

      def filter_by_topic_framework value
        restrict_by_cql(
          :topic, :metric_id,
          right: :topic_framework, refer_to: ["in", value].flatten, return: :left_id
        )
      end

      def filter_by_dataset value
        dataset_restriction :metric_id, :metric, value
      end

      def filter_by_bookmark value
        bookmark_restriction :metric_id, value
      end

      def filter_by_metric_keyword value
        restrict_by_cql :title, "title_id", name: [:match, value]
      end

      def filter_by_license value
        restrict_by_cql :license, :metric_id,
                        right: :license,
                        in: Array.wrap(value),
                        return: :left_id
      end

      def filter_by_metric value
        filter :metric_id, Array.wrap(value).map(&:card_id)
      end

      # note: :false and "false" work; false doesn't (can't survive #process_filter)
      def filter_by_published value
        return if value.to_s == "all" && stewards_all?
        @conditions <<
          case value.to_s
          when "true"
            published_condition
          when "false"
            unpublished_condition
          when "all"
            # Is this right?? Seems like we want _no_ conditions... Explain?
            "(#{published_condition} OR (#{unpublished_condition}))"
          end
      end

      def filter_by_benchmark value
        operator = value == "1" ? "=" : "!="
        filter :benchmark, "1", operator
      end

      private

      # Wikirate team members are stewards of all metrics
      def stewards_all?
        Auth.always_ok? || Auth.current.stewards_all?
      end

      def published_condition
        # handles nil and false
        "#{lookup_table}.unpublished is not true"
      end

      def unpublished_condition
        cond = "#{lookup_table}.unpublished is true"
        return cond if stewards_all?
        metric_ids = Card::Auth.current.stewarded_metric_ids
        if metric_ids.empty?
          @empty_result = true
        else
          "#{cond} and #{lookup_table}.metric_id in (#{metric_ids.join ', '})"
        end
      end

      def normalize_filter_args
        @filter_args[:published] = true unless @filter_args.key? :published
      end

      # also used by metric_filters.rb
      def dataset_restriction field, codename, dataset
        return (@empty_result = true) unless (referer = [dataset, codename].card)

        if referer.count > 200
          dataset_subquery_restriction field, referer.id
        else
          filter field, referer.item_ids
        end
      end

      def dataset_subquery_restriction field, referer_id
        reference_subquery =
          "SELECT referee_id FROM card_references " \
            "USE INDEX (card_references_referer_id_index) " \
            "WHERE referer_id = #{referer_id}"
        restrict_by_subquery field, reference_subquery
      end

      # TODO: move to a more general spot
      def restrict_by_subquery field, subquery
        @conditions << "#{filter_table field}.#{field} IN (#{subquery})"
      end

      def dataset_year_restriction dataset
        years = dataset&.card&.years
        filter :year, years if years.present?
      end

      # also used by metric_filters.rb
      def bookmark_restriction field, value
        Card::Bookmark.id_restriction(value.to_sym == :bookmark) do |restriction|
          operator = restriction.shift # restriction looks like cql, eg ["in", 1, 2]
          filter field, restriction, operator
        end
      end
    end
  end
end
