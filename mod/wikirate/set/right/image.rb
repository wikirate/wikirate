format :html do

  view :missing do |args|
    parent_type_name = Card[card.left.type_id].name
    missing_image_card = Card["#{parent_type_name}+missing_image_card"]
    if missing_image_card
      core = subformat( missing_image_card )._render_core args
    else
      super args
    end
  end
end