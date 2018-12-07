module Formula
  class Calculator
    class InputItem
      attr_reader :card_id, :input_values
      delegate :company_list, :all_input_required?, to: :input_values

      def initialize input_values, input_index
        @input_values = input_values
        @input_index = input_index
        @input_card = input_values.input_cards[input_index]
        @card_id = @input_card.id
        extend CompanyOption if company_option?
        extend YearOption if year_option?
        initialize_decorator
      end

      def value_store
        @value_store ||= ValueStore.new true
      end

      def value_for company, year
        value_store.get company, year
      end

      def initialize_decorator
      end

      def year_option?
        year_option.present? && year_option != "0"
      end

      def company_option?
        company_option.present?
      end

      def year_option
        @year_option ||=
          normalize_year_option @input_values.year_options[@input_index]
      end

      def company_option
        @company_option ||=
          normalize_company_option @input_values.company_options[@input_index]
      end

      def store_value company_id, year, value
        value_store.add company_id, year, value
        @input_values.companies_with_values.add company_id, year
      end

      def values_by_year company
        value_store.get company
      end

      def normalize_year_option option
        return unless option.present?
        option.sub("year:", "").tr("?", "0").strip
      end

      def normalize_company_option option
        return unless option.present?
        option.sub("company:", "").strip
      end
    end
  end
end
