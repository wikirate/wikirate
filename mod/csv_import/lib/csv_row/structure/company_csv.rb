class CSVRow
  module Structure
    # To be used by CSVRow classes to handle company imports.
    # Expects
    #  - a company name in row[:company],
    #  - a suggestion (of the company mapper gem) for the corresponding company in the
    #    database in extra_data[:suggestion] and possibly a user correction of the mapping
    #    in extra_data[:corrections][:company].
    #    The user correction overrides the suggestion.
    class CompanyCSV < CSVRow
      def initialize row, index, import_manager = nil, company_key=:company
        super(row, index, import_manager)
        @company_key = company_key
        @file_company = @before_corrected[@company_key] || @row[@company_key]
        correct_company
      end

      def merge_corrections
        super
        correct_company
      end

      def correct_company
        case match_type
        when :alias
          @row[@company_key] = suggested_company
        when :partial
          @row[@company_key] = corrected_company || suggested_company
        when :none
          @row[@company_key] = corrected_company if user_corrected_company?
        end
      end

      def import
        ensure_company_exists
        add_alias
      end

      def ensure_company_exists
        if Card.exists?(company)
          if Card[company].type_id != Card::WikirateCompanyID
            error "#{company} is not a company"
          end
        else
          add_card name: company, type_id: Card::WikirateCompanyID
        end
      end

      def add_alias?
        @match_type == :partial || (@match_type == :none && user_corrected_company?)
      end

      def add_alias
        return unless add_alias?
        card_name = company.to_name.field(:aliases)
        new_content =
          if (aliases_card = Card[card_name])
            aliases_card.add_item @file_company
            aliases_card.content
          else
            @file_company
          end
        add_card name: card_name, content: new_content, type_id: Card::PointerID
      end

      def company
        @row[@company_key]
      end

      def suggested_company
        @extra_data["#{@company_key}_suggestion".to_sym]
      end

      def corrected_company
        @corrections[@company_key]
      end

      def match_type
        return unless @extra_data.present?
        @match_type ||= @extra_data["#{@company_key}_match_type".to_sym]&.to_sym
      end

      def user_corrected_company?
        @corrections[@company_key].present?
      end
    end
  end
end
