format :html do 
  view :missing do |args|
    username = card.cardname.left
    if user_image = Card["#{username}+image"]
      subformat(user_image).render args[:home_view],:size=>args[:size]
    else
      super args  
    end
  end

end