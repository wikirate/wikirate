# -*- encoding : utf-8 -*-

require_relative "../../script/csv_import/wikipedia/wikipedia_csv_row"
require_relative "../../script/csv_import/csv_file"

class UpdateWikipediaMapping < Card::Migration
  #disable_ddl_transaction!

  def up
    csv_path = data_path "wikirate_to_wikipedia.csv"
    Card::Auth.current_id = Card.fetch_id "Vasiliki Gkatziaki"
    CSVFile.new(csv_path, WikipediaCSVRow).import! error_policy: :skip
  end
end
