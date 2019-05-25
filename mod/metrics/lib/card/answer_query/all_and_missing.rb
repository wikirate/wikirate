class Card
  class AnswerQuery
    # methods related to all / not-researched status
    module AllAndMissing
      private

      def find_all?
        @filter_args[:status]&.to_sym == :all
      end

      def find_missing? extra_filter={}
        status_filter_value(extra_filter) == :none
      end

      def status_filter_value extra_filter={}
        (extra_filter[:status] || @filter_args[:status])&.to_sym
      end

      def all_answers
        all_answer_query.run
      end

      def missing_answers
        missing_answer_query.run
      end

      def class_tag
        @class_tag ||= self.class.to_s.split("::").last
      end

      def all_answer_query
        @all_answer_query ||= query_variant AllAnswerQuery
      end

      def missing_answer_query
        @missing_answer_query ||= query_variant MissingAnswerQuery
      end

      def query_variant base
        base.const_get(class_tag).new @filter_args, @sort_args, @paging_args
      end
    end
  end
end
