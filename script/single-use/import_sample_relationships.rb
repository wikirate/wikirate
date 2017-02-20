require_relative "relationship_import/relationship_answers_csv"
require_relative "relationship_import/relationship_metrics_csv"

metrics_path = File.expand_path "../relationship_import/data/metrics.csv"
answers_path = File.expand_path "../relationship_import/data/answers.csv"

RelationshipMetricsCSV.new(metrics_path).import!
RelationshipAnswersCSV.new(answers_path).import!
