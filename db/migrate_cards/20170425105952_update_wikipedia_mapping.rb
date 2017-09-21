# -*- encoding : utf-8 -*-

require_relative "../../script/csv_import/wikipedia/wikipedia_csv_row"
require_relative "../../mod/csv_import/lib/csv_file"

class UpdateWikipediaMapping < Card::Migration
  disable_ddl_transaction!

  def user
    Rails.env.test? ? "Joe Admin" : "Vasiliki Gkatziaki"
  end

  def up
    csv_path = data_path "wikirate_to_wikipedia.csv"
    CSVFile.new(csv_path, WikipediaCSVRow, col_sep: ";")
           .import user: user,  error_policy: :report
  end
end
