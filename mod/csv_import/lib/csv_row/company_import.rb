class CSVRow
  # To be used by CSVRow classes to handle company imports.
  # Expects
  #  - a company name in row[:company],
  #  - a suggestion (of the company mapper gem) for the corresponding company in the
  #    database in extra_data[:suggestion] and possibly a user correction of the mapping
  #    in extra_data[:corrections][:company].
  #    The user correction overrides the suggestion.
  module CompanyImport
    def initialize row, index, import_manager=nil
      @file_company = row[:company]
      super # overrides company with correction
      return unless @extra_data.present?
      case (@match_type = @extra_data[:match_type]&.to_sym)
      when :alias
        @row[:company] = suggested_company
      when :partial
        @row[:company] = @corrections[:company] || suggested_company
      when :none
        @row[:company] = @corrections[:company] if user_corrected_company?
      end
    end

    def import_company
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

    def suggested_company
      @extra_data[:suggestion]
    end

    def user_corrected_company?
      @corrections[:company].present?
    end
  end
end
