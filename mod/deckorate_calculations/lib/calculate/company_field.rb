class Calculate
  # This "Calculator" class replicates the behavior of
  # more sophisticated Calculate::Calculator classes but performs a much
  # simpler "calculation" - it just takes values from company fields
  # and creates answers out of them.
  class CompanyField < Calculator
    YEAR = "2019".freeze

    attr_reader :field_code, :card

    def initialize field_code, card=nil
      @field_code = field_code
      @card = card
      @errors = []
    end

    # company fields don't depend on any other answers
    def answers_for _company_id, _year
      []
    end

    # formula is always valid
    def ready?
      true
    end

    def result companies: nil, years: nil
      requiring_year years, {} do
        field_calculations companies
      end
    end

    def inputs_for _company, _year
      []
    end

    # def formula_for company, year
    #   requiring_year year, "No value" do
    #     "Pulled from #{field_name} field of #{card.format.link_to_card company}"
    #   end
    # end

    private

    def field_calculations company
      company_fields(company).each_with_object([]) do |field_card, array|
        array << calculation(field_card.left_id, field_card.answer_value)
      end
    end

    def calculation company, value
      Calculation.new company, YEAR, value: value
    end

    def company_fields company
      if company
        company_id = company.card_id
        Card.search left_id: company_id, right_id: field_id
      else
        Card.search left: { type_id: Card::CompanyID }, right_id: field_id
      end
    end

    def requiring_year year, default_result
      if year && year.to_s != YEAR
        default_result
      else
        yield
      end
    end

    def field_id
      Card::Codename.id field_code
    end

    def field_name
      field_code.cardname
    end
  end
end
