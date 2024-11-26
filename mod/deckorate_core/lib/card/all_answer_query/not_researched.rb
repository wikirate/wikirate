class Card
  class AllAnswerQuery
    # handles the instantiation of not_researched cards
    module NotResearched
      private

      def not_researched_card name
        Card.new name: new_name(name), type_id: Card::AnswerID
      end

      def new_name partner_name
        if partner == :company
          Card::Name[metric_card.name, partner_name, new_name_year]
        else
          Card::Name[partner_name, company_card.name, new_name_year]
        end
      end

      def new_name_year
        @new_name_year ||= filtered_year || latest_applicable_year
      end

      # not sure this really matters; year isn't displayed or included in link
      # at present
      def latest_applicable_year
        if (years = applicable_years).present?
          years.last
        else
          Time.now.year.to_s
        end
      end
    end
  end
end
