format :html do 
  view :missing do |args|
    username = card.cardname.left
    # user's image is in +image but in metric page, we are using +logo
    # a virtual card with structure won't work as it cannot have the args from +logo
    if user_image = Card["#{username}+image"]
      subformat(user_image).render args[:home_view],:size=>args[:size]
    else
      super args  
    end
  end

end