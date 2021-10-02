class Calculate
  class Wolfram
    # Provide methods to handle "Unknown" input values for Wolfram formulas
    module Validation
      WHITELIST = ::Set.new(
        %w[Boole If Switch Map
           Count Pick Cases FirstCase
           MaximalBy MinimalBy
           AllTrue AnyTrue NoneTrue
           Sort SortBy
           StringMatchQ RegularExpression
           Take TakeLargest TakeSmallest TakeLargestBy TakeSmallestBy
           ContainsAll ContainsNone ContainsAny ContainsOnly ContainsExactly
           Mean Variance StandardDeviation Median Quantile Covariance] +
          Ruby::FUNCTIONS.keys
      ).freeze

      def safety_checks
        super
        # check_whitelist
      end

      def check_whitelist
        invalid_method_calls.each do |bad_word|
          @errors << "unknown or not supported method: #{bad_word}"
        end
      end

      private

      def invalid_method_calls
        strip_safe_parts.scan(/[a-zA-Z][a-zA-Z]+/).reject do |word|
          WHITELIST.include? word
        end
      end

      def strip_safe_parts
        Calculator.remove_quotes(Calculator.remove_nests(@unsafe))
      end
    end
  end
end
