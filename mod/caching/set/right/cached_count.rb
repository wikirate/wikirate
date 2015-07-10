format :html do
  view :missing  do |args|
    if @card.new_card? and @card.left
      @card.left.update_cached_count
      @card = Card.fetch(card.name)
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end