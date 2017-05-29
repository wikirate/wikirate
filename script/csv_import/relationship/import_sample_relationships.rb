require_relative "../../../config/environment"

require_relative "relationship_answer_csv_row"
require_relative "relationship_metric_csv_row"
require_relative "../csv_file"

metrics_path = File.expand_path "../data/metrics.csv", __FILE__
answers_path = File.expand_path "../data/answers.csv", __FILE__

Card::Auth.current_id = Card.fetch_id("Philipp Kuehl")

CSVFile.new(metrics_path, RelationshipMetricCSVRow).import
CSVFile.new(answers_path, RelationshipAnswerCSVRow).import
