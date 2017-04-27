require_relative "wikipedia_csv_row"

class LogoCSVRow < WikipediaCSVRow
  @columns = [:wikirate_id, :wikirate_name, :wikipedia_url, :logo]
  @required = :all

  def normalize_logo val
    "http:" + val
  end

  def import
    puts wikirate_name
    ensure_card [wikirate_id, :image], remote_url: logo,
                type_id: Card::ImageID
  end
end
