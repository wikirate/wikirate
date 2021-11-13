class Card
  class MetricQuery
    # metric-related filters (also used by AnswerQuery)
    module MetricFilters
      def topic_query value
        restrict_by_cql(
          :metric_id,
          right_plus: [:wikirate_topic, { refer_to: ["in", value].flatten }]
        )
      end
      alias_method :wikirate_topic_query, :topic_query

      def dataset_query value
        dataset_restriction :metric_id, :metric, value
      end

      def bookmark_query value
        bookmark_restriction :metric_id, value
      end

      # note: :false and "false" work; false doesn't (can't survive #process_filter)
      def published_query value
        return if value.to_s == "all" && stewards_all?
        @conditions <<
          case value.to_s
          when "true"
            published_condition
          when "false"
            unpublished_condition
          when "all"
            "(#{published_condition} OR (#{unpublished_condition}))"
          end
      end

      private

      # WikiRate team members are stewards of all metrics
      def stewards_all?
        Card::Auth.current.stewards_all?
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

      # also used by metric_and_company_filters.rb
      def dataset_restriction field, codename, dataset
        restrict_by_cql field, referred_to_by: "#{dataset}+#{codename.cardname}"
      end

      def dataset_year_restriction dataset
        years = dataset&.card&.years
        filter :year, years if years.present?
      end

      # also used by metric_and_company_filters.rb
      def bookmark_restriction field, value
        Card::Bookmark.id_restriction(value.to_sym == :bookmark) do |restriction|
          operator = restriction.shift # restriction looks like cql, eg ["in", 1, 2]
          filter field, restriction, operator
        end
      end
    end
  end
end
