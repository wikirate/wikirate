class Calculate
  class Calculator
    # It finds all applicable answer values to a formula's input metrics and prepares
    # them for calculating the formula values.
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class Input
      include Answers

      attr_reader :input_list, :result_cache
      delegate :no_mandatories?, :validate, to: :input_list

      # @param input_array [Array of Hashes] input_array
      # @param input_cast [Proc] a block that is called for every input value
      def initialize input_array, &input_cast
        @input_cast = input_cast
        @result_cache = ResultCache.new
        @input_list = InputList.new input_array.map(&:symbolize_keys)
      end

      # @param :companies [Array of Integers] only yield input for given companies
      # @option :years [Array of Integers] :year only yield input for given years
      def each companies: [], years: []
        each_answer companies: companies, years: years do |answers, company_id, year|
          yield answers, company_id, year if normalize_answers answers
        end
      end

      # input values for a given company/year
      # @return [Array<String, Symbol, Integer, Array>]
      def input_for company_id, year
        with_integers company_id, year do |c, y|
          search_values_for company_id: c, year: y
          normalize_answers(fetch_answer(c, y)).map(&:value)
        end
      end

      # @return [Array<Array>] for the given company and year returns a list of lists of
      # Answer objects. Each item in the outer list corresponds to an input.
      # Most inputs have only one item, but some have more, so we return an Array of
      # answers for each input
      def answers_for company_id, year
        with_integers company_id, year do |c, y|
          input_list.map do |input_item|
            input_item.answers_for(c, y).to_a
          end
        end
      end

      private

      # yields value, company_id, and year (as integer) for each result
      def each_answer companies: [], years: [], &block
        if companies.present? && years.present?
          values_for_companies_and_years companies, years, &block
        elsif years.present?
          values_for_years years, &block
        elsif companies.present?
          values_for_companies companies, &block
        else
          all_values(&block)
        end
      end

      def with_integers company_id, year
        yield company_id&.card_id, year&.to_i
      end

      def each_year years, &block
        Array.wrap(years).map(&:to_i).each(&block)
      end

      def each_company companies, &block
        Array.wrap(companies).map(&:card_id).each(&block)
      end

      def normalize_answers answers
        answers&.map do |answer|
          answer.cast { |val| @input_cast.call val } if @input_cast && !answer.nil?
          answer
        end
      end

      def search_values_for company_id: nil, year: nil
        while_full_input_set_possible company_id, year do |input_item, result_space|
          input_item.search_value_for result_space, company_id: company_id, year: year
        end
      end

      def while_full_input_set_possible company_id=nil, year=nil
        @result_cache.track_search company_id, year, no_mandatories? do |result_space|
          # subtle but IMPORTANT:
          # The "sort" call puts all items without non_researched option in front.
          # This way the search space becomes restricted before we have to deal with input
          # items that have a default value for the whole company-year-space.
          input_list.sort.each do |input_item|
            yield input_item, result_space
            # skip remaining input items if there are no candidates left that can have
            # values for all input items
            break if result_space.run_out_of_options?
          end
        end
      end

      # optimization idea, never fully implemented:
      #
      # def cached_lookup
      #   @cached_lookup ||= ::Answer.where(metric_id: input_ids) # .sort(year: :desc)
      #                            .pluck(:metric_id, :company_id, :year, :value)
      #                            .each_with_object({}) do |(m, c, y, v), h|
      #     h[m] ||= {}
      #     h[m][c] ||= {}
      #     h[m][c][y] = v
      #   end
      # end
    end
  end
end
