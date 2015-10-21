card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"


format :html do
  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  def view_caching?
    true
  end
end

format :json do
  view :content do
    Card.search(right: 'value', left: {
      left: { left: card.name },
      right: { type: 'year' }
      }).map do |card|
      [card.cardname.left_name.left_name.right, card.cardname.left_name.right, card.content]
    end.to_json
  end
end
