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
  end
end
