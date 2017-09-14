format :html do
  view :missing do |args|
    # try to get type+missing_image_card's image to display
    # EX: user+missing_image_card
    if card.left.present?
      parent_type_card = Card[card.left.type_id]
      missing_image_card = parent_type_card.fetch(trait: :missing_image_card)
      if missing_image_card
        subformat(missing_image_card)._render voo.home_view, args
      else
        super()
      end
    else
      super()
    end
  end
end
