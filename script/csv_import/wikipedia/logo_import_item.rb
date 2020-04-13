require_relative "wikipedia_import_item"

class LogoImportItem < WikipediaImportItem
  @columns = [:wikirate_id, :wikirate_name, :wikipedia_url, :logo]

  def normalize_logo val
    "https:" + val
  end

  def import
    return if Card[wikirate_id, :image]
    puts wikirate_name
    ensure_card [wikirate_id, :image], remote_image_url: logo,
                                       type_id: Card::ImageID
  end
end
