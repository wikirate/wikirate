require_relative "../../../config/environment"

require_relative "relationship_answer_import_item"
require_relative "relationship_metric_import_item"
require_relative "../csv_file"

metrics_path = File.expand_path "../data/HnM_relationship_metric.csv", __FILE__
answers_path = File.expand_path "../data/HnM_relationship_answers_small.csv", __FILE__

CsvFile.new(metrics_path, RelationshipMetricImportItem)
       .import user: "Philipp Kuehl"
CsvFile.new(answers_path, RelationshipAnswerImportItem)
       .import user: "Philipp Kuehl"
