require_relative "wikipedia_csv_row"

class LogoCsvRow < WikipediaCsvRow
  @columns = [:wikirate_id, :wikirate_name, :wikipedia_url, :logo]
  @required = :all

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
