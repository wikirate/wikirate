require_relative "../../../config/environment"
require_relative "wikipedia_import_item"
require_relative "../csv_file"

#csv_path = File.expand_path "../data/error.csv", __FILE__
csv_path = File.expand_path "../data/wikirate_to_wikipedia.csv", __FILE__
CsvFile.new(csv_path, WikipediaImportItem)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
