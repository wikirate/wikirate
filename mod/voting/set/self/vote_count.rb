format :csv do
  view :core do |args|
    res = ''
    Card.search(:type_id=>UserID).each do |user|
      user.upvotes_card.item_cards.each do |uv|
        res += CSV.generate_line [user.id, uv.id, "up", uv.created_at]
      end
      user.downvotes_card.item_cards.each do |dv|
        res += CSV.generate_line [user.id, dv.id, "down", dv.created_at]
      end
    end
    res
  end
end