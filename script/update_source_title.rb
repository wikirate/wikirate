#!/usr/bin/env ruby

require File.dirname(__FILE__) + '../../config/environment'


Wagn.config.perform_deliveries = false
Card::Auth.as_bot


Card.search(:type=>Card::WebpageID).each do |card|
	cardname = card.name 

	if Card[cardname+"+link"] and ( !Card[cardname+"+title"] or !Card[cardname+"+description"] or !Card[cardname+"+image url"] )
		begin
			url=Card[cardname+"+link"].content
			preview = LinkThumbnailer.generate url
			if !Card[cardname+"+image url"]
				if preview.images.length > 0
					Card.create! :name=>cardname+"+image url", :content=>preview.images.first.src.to_s
				end
			end
			if !Card[cardname+"+title"] && preview.title
				Card.create! :name=>cardname+"+title", :content=>preview.title
			end
			if !Card[cardname+"+description"] && preview.description
				Card.create! :name=>cardname+"+description", :content=>preview.description
			end
		rescue
			puts "[[#{ cardname }]]:  #{ url }"
		end
	end
end