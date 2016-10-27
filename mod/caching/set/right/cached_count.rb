def followable?
  false
end

def history?
  false
end

format :html do
  view :missing do |args|
    if @card.new_card? &&
       (l = @card.left) &&
       l.respond_to?(:update_cached_count)
      l.update_cached_count
      @card = Card.fetch(card.name)
      render(@denied_view, args)
    else
      super(args)
    end
  end

  view :new, :missing
end
