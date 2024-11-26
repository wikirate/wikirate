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
      current_symbol ? routes.keys.index(current_symbol) : route
    end

    def route_symbol
      routes.keys[route]
    end

    def fetch_editor_id
      card.value_card.updater_id if value_updated?
    end

    def fetch_creator_id
      card.creator_id || Card::Auth.current_id
    end

    # NOTE: the created and updated fields have a logic that differs slightly
    # from the answer card

    def fetch_created_at
      card&.value_card&.created_at || created_at || Time.now
    end

    # I'm not sure this is still needed.  value card updates should update the card
    # test and, if possible, remove
    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)

      [card.updated_at, vc.updated_at].compact.max
    end

    private

    def routes
      ROUTES
    end

    def value_updated?
      return unless (vc = card.value_card)&.real?

      vc.updated_at && vc.updated_at > vc.created_at
    end
  end
end
