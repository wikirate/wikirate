require_relative "../../config/environment"

require_relative "relationship_answer_csv"
require_relative "relationship_metric_csv"
require_relative "../csv_file"

metrics_path = File.expand_path "../relationship_import/data/metrics.csv", __FILE__
answers_path = File.expand_path "../relationship_import/data/answers.csv", __FILE__

CSVFile.new(metrics_path, RelationshipMetricsCSVRow)
       .import user: "Philipp Kuehl"
CSVFile.new(answers_path, RelationshipAnswersCSVRow)
       .import user: "Philipp Kuehl"
