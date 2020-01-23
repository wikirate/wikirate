require_relative "../../../config/environment"

require_relative "relationship_answer_csv_row"
require_relative "relationship_metric_csv_row"
require_relative "../csv_file"

metrics_path = File.expand_path "../data/metrics.csv", __FILE__
answers_path = File.expand_path "../data/answers.csv", __FILE__

CsvFile.new(metrics_path, CsvRow::Structure::RelationshipMetricCSV)
       .import user: "Philipp Kuehl"
CsvFile.new(answers_path, CsvRow::Structure::RelationshipAnswerCsv)
       .import user: "Philipp Kuehl"
