
def find_duplicates url
  duplicate_wql = { :right=>Card[:wikirate_link].name, :content=>url ,:left=>{:type_id=>Card::WebpageID}}
  duplicates = Card.search duplicate_wql
end

format :json do
  view :metadata do |args|

    metadata = Hash.new
    metadata["title"] = ""
    metadata["description"]  = ""
    metadata["image_url"]  = ""
    metadata["website"] = ""
    metadata["error"] = ""
    url = Card::Env.params[:url]||args[:url] ||""
    if url.empty?
      metadata["error"] = 'empty url'
      return metadata.to_json
    end
    begin      
      metadata["website"] = URI(url).host
    rescue    
    end
    if !metadata["website"]
      metadata["error"] = 'invalid url' 
      return metadata.to_json
    end
    duplicates = card.find_duplicates url
    if duplicates.any?
      
      origin_link_card = duplicates.first
      origin_page_card = origin_link_card.left
      metadata["title"] = Card["#{origin_page_card.name}+title"].content
      metadata["description"]  = Card["#{origin_page_card.name}+description"].content
      metadata["image_url"]  = Card["#{origin_page_card.name}+image_url"].content
    else
      begin 
        preview = LinkThumbnailer.generate url
        if preview.images.length > 0
          image_url = preview.images.first.src.to_s
        end
          metadata["title"] = preview.title
          metadata["description"]  = preview.description
          metadata["image_url"]  = image_url
      rescue
        Rails.logger.info "Fail to extract information from the #{ url }"
      end
    end
    metadata.to_json
  end
end