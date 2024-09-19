class Card
  class AnswerQuery
    # conditions and condition support methods for company-related fields.
    module CompanyFilters
      def filter_by_company_group value
        multi_company do
          group_lists = Array.wrap(value).map { |v| [v, :company].cardname }
          restrict_by_cql :groups, :company_id, referred_to_by: group_lists
        end
      end

      def filter_by_company value
        filter :company_id, Array.wrap(value).map(&:card_id)
      end

      def filter_by_company_keyword value
        restrict_by_cql :company_name, :company_id,
                        name: [:match, value], type: :company
      end

      def filter_by_country value
        filter_by_company_filter :countries, :country_condition, value
      end

      def filter_by_company_category value
        filter_by_company_filter :categories, :category_condition, value
      end

      def filter_by_company_identifier value
        CompanyFilterCql.company_identifier_clauses(value) do |type_clause, value_clause|
          multi_company do
            restrict_by_cql :ident, :company_id,
                            value_clause.merge(return: :left_id, right: type_clause)
          end
        end
      end

      private

      def filter_by_company_filter table, condition_method, value
        company_answer_join table
        @conditions << CompanyFilterCql.send(condition_method)
        @values << Array.wrap(value)
      end

      def single_company?
        @filter_args[:company_id].is_a? Integer
      end

      def multi_company
        single_company? ? return : yield
      end

      def company_card
        single_company? ? (@company_card ||= Card[@filter_args[:company_id]]) : return
      end

      def company_answer_join table
        @joins << "JOIN answers AS #{table} ON answers.company_id = #{table}.company_id"
      end
    end
  end
end
