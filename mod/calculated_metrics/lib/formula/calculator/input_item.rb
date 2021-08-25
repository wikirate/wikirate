module Formula
  class Calculator
    # {InputItem} represents a nested metric in a formula.
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
      include Defaults
      include CompanyDependentInput
      include Options

      INPUT_ANSWER_FIELDS = %i[company_id year value unpublished verification].freeze

      def type
        @type ||= @input_card.simple_value_type_code
      end

      attr_writer :search_space
      attr_reader :card_id, :input_list, :result_space
      delegate :answer_candidates, to: :result_space
      delegate :parser, to: :input_list

      # We instantiate with a super class because we dynamically include a lot of modules
      # based on options, and included modules don't override methods defined directly
      # on the including class. (Alternatively we could move everything out of here into
      # modules and have them override each other. Arguably more elegant; we got here
      # because of legacy reasons, and it's not bad enough to inspire me to change the
      # approach as of Aug 2021 --efm)
      def self.item_class type_id
        type_id == Card::MetricID ? self : InvalidInputItem
      end

      def initialize input_list, input_index
        @input_list = input_list
        @input_index = input_index

        @input_card = parser.input_cards[input_index]
        @card_id = @input_card.id
        initialize_options
        # @value_store = value_store_class.new
      end

      # @param [Array<company_id>] company_id when given search only for answers for those
      #    companies
      # @param [Array<year>] year when given search only for answers for those years
      def search_value_for result_space, company_id:, year:
        return search result_space if company_id.nil? && year.nil?

        @result_space = result_space
        with_restricted_search_space company_id, year do
          search result_space
        end
      end

      def answers_for company_id, year
        @search_space = SearchSpace.new company_id, year
        answers
      end

      def search result_space
        @result_space = result_space
        @result_slice = ResultSlice.new
        full_search
        after_search
      end

      def search_space
        @search_space ||= result_space.answer_candidates
      end

      # Find answer for the given input card and cache the result.
      # If year is given look only for that year
      def full_search
        year_value_pairs_by_company.each do |company_id, year_value_hash|
          translate_years(year_value_hash.keys).each do |year|
            store_value company_id, year, apply_year_option(year_value_hash, year)
          end
        end
      end

      def after_search
        result_space.update @result_slice, mandatory?
      end

      def store_value company_id, year, value
        value_store.add company_id, year, value
        update_result_slice company_id, year, value
      end

      # @return a hash { year => value } if year is nil otherwise only value.
      #   Value is usually a string, but it can be an array of strings if the input item
      #   uses an option that generates multiple values for one year like a
      #   year option "year: 2000..-1"
      def answer_for company_id, year
        value_store.get company_id, year
      end

      def value_store
        @value_store ||= value_store_class.new
      end

      def <=> other
        sort_index <=> other.sort_index
      end

      # Searches for all metric answers for this metric input.
      def answers
        Answer.where answer_query
      end

      private

      def each_input_answer rel
        rel.pluck(*INPUT_ANSWER_FIELDS).each do |fields|
          company_id = fields.shift
          year = fields.shift
          input_answer = InputAnswer.new self, company_id, year
          input_answer.assign(*fields)
          yield input_answer
        end
      end

      # used for CompanyOption
      def combined_input_answers company_ids, year
        sub_input_answers = [].tap do |array|
          each_input_answer sub_answers_rel(company_ids, year) do |input_answer|
            array << input_answer
          end
        end
        consolidated_input_answer sub_input_answers, year
      end

      def sub_answers_rel company_ids, year
        Answer.where metric_id: card_id, company_id: company_ids, year: year
      end

      def consolidated_input_answer input_answers, year
        value = input_answers.map(&:value)
        unpublished = input_answers.find(&:unpublished)
        verification = input_answers.map(&:verification).compact.min || 1
        InputAnswer.new(self, nil, year).assign value, unpublished, verification
      end

      # used for CompanyOption
      def years_from_db company_ids
        Answer.select(:year).distinct
              .where(metric_id: card_id, company_id: company_ids)
              .distinct.pluck(:year).map(&:to_i)
      end

      def search_company_ids
        Answer.select(:company_id).distinct.where(metric_id: card_id).pluck(:company_id)
      end

      def unknown! answer
        answer.value = :unknown
        throw :cancel_calculation, [answer]
      end

      def with_restricted_search_space company_id, year
        @search_space = SearchSpace.new company_id, year
        @search_space.intersect! result_space.answer_candidates
        yield
      ensure
        @search_space = nil
      end
    end
  end
end
