format :html do
  view :missing  do |args|
    if @card.new_card? and @card.left
      Auth.as_bot do
        @card.left.update_contribution_count

        # update_contribution_count saved the card
        # don't save it again
        @card = Card.fetch(card.name) || @card
        @card.save! if @card.new_card?
      end
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end

