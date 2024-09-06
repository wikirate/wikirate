class Answer
  # Methods shared by answers and relationships
  module AndRelationship
    def no_refresh
      %w[id imported] # imported is deprecated
    end

    def fetch_year
      card.year.to_i
    end

    def fetch_route
      current_symbol = card.value_card&.current_route_symbol
      current_symbol ? ROUTES.index(current_symbol) : route
    end

    def route_symbol
      ROUTES[route]
    end

    def fetch_editor_id
      card.value_card.updater_id if value_updated?
    end

    private

    def value_updated?
      return unless (vc = card.value_card)&.real?

      vc.updated_at && vc.updated_at > vc.created_at
    end
  end
end
