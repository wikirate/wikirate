class Calculate
  class Calculator
    # Each {InputItem} represents a nested metric in a formula.
    # For example "{{Jedi+friendliness|year: -1}}" in the formula
    # "{{Jedi+friendliness|year: -1}} + 10 / {{Jedi+deadliness}}"
    #
    # It is responsible for finding all relevant values for that input item.
    # How this is handled depends on the nest options (year and/or company)
    # The logic for the nest options is in the modules {CompanyOption} and {YearOption}
    #
    # A metric with a fixed company is option company independent.
    # That's why the company dependency is separated into the modules
    # {CompanyDependentInput} and {CompanyIndependentInput}
    class InputItem
      include ValidationChecks
      include Search
      include Defaults
      include Options

      INPUT_ANSWER_FIELDS = %i[company_id year id value unpublished verification].freeze

      attr_reader :input_card, :options, :input_index, :input_count, :result_space
      delegate :answer_candidates, to: :result_space

      # We instantiate with a super class because we dynamically include a lot of modules
      # based on options, and included modules don't override methods defined directly
      # on the including class. (Alternatively we could move everything out of here into
      # modules and have them override each other. Arguably more elegant; we got here
      # because of legacy reasons, and it's not bad enough to inspire me to change the
      # approach as of Aug 2021 --efm)
      def self.item_class type_id
        type_id == Card::MetricID ? self : InvalidInputItem
      end

      def initialize input_card, input_index, input_count, options
        @input_card = input_card
        @input_index = input_index
        @input_count = input_count
        @options = options
        initialize_options
      end

      def type
        @type ||= @input_card.simple_value_type_code
      end

      # @param [Array<company_id>] company_id when given search only for answers for those
      #    companies
      # @param [Array<year>] year when given search only for answers for those years
      def search_value_for result_space, company_id: nil, year: nil
        return search result_space if company_id.nil? && year.nil?

        @result_space = result_space
        with_restricted_search_space company_id, year do
          search result_space
        end
      end

      def answers_for company_id, year
        @search_space = SearchSpace.new company_id, year
        if option?(:company) || year_option?
          # cannot do simple query
          nonstandard_answers
        else
          answers
        end
      end

      # @return a hash { year => value } if year is nil otherwise only value.
      #   Value is usually a string, but it can be an array of strings if the input item
      #   uses an option that generates multiple values for one year like a
      #   year option "year: 2000..-1"
      def answer_for company_id, year
        value_store.get company_id, year
      end

      def <=> other
        sort_index <=> other.sort_index
      end

      private

      # don't need to pass company_id and year because it's
      # captured in the searchspace
      def nonstandard_answers
        answer_ids = []
        full_search do |_company_id, _year, input_answer|
          answer_ids << input_answer.lookup_ids
        end
        ::Answer.where id: answer_ids.flatten.uniq
      end

      def unknown! answer
        answer.value = :unknown
        throw :cancel_calculation, [answer]
      end
    end
  end
end
