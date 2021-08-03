class Card
  class AllAnswerQuery
    # handles the instantiation of not_researched cards
    module NotResearched
      private

      def not_researched_card name
        Card.new name: new_name(name), type_id: Card::MetricAnswerID
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
        year.blank? || year.to_s == "latest" ? latest_applicable_year : year
      end

      def latest_applicable_year
        if (years = applicable_years)&.present?
          years.last
        else
          Time.now.year
        end
      end

      # not sure this really matters; year isn't displayed or included in link
      # at present
      def applicable_years
        return unless @partner == :company

        metric_card&.year_card&.item_names&.sort
      end
    end
  end
end
