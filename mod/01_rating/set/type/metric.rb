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
