require_relative "wikipedia_csv_row"

class LogoCSVRow < WikipediaCSVRow
  @columns = [:wikirate_id, :wikirate_name, :wikipedia_url, :logo]
  @required = :all

  def normalize_logo val
    "https:" + val
  end

  def import
    puts wikirate_name
    return if Card[wikirate_id, :image]
    ensure_card [wikirate_id, :image], remote_image_url: logo,
                                       type_id: Card::ImageID
  end
end
