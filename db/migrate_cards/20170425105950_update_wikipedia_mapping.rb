# -*- encoding : utf-8 -*-

require_relative "../../script/csv_import/wikipedia/wikipedia_csv_file"

class UpdateWikipediaMapping < Card::Migration
  disable_ddl_transaction!

  def up
    csv_path = File.expand_path "../data/wikirate_to_wikipedia.csv", __FILE__
    Card::Auth.current_id = Card.fetch_id "Vasiliki Gkatziaki"
    WikipediaCSVFile.new(csv_path).import!
  end
end
