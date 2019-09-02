class Card
  class AllAnswerQuery
    # handles the instantiation of not_researched cards
    module NotResearched
      private

      def not_researched_card name
        Card.new name: new_name(name), type_id: MetricAnswerID
      end

      def new_name partner_name
        if @partner == :company
          Card::Name[metric_card.name, partner_name, new_name_year]
        else
          Card::Name[partner_name, company_card.name, new_name_year]
        end
      end

      def new_name_year
        @new_name_year ||= determine_new_name_year.to_s
      end

      def determine_new_name_year
        year = @filter_args[:year]
        year.blank? || year.to_s == "latest" ? Time.now.year : year
      end
    end
  end
end
