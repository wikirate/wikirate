require_relative "../../config/environment"

require_relative "relationship_import/relationship_answers_csv"
require_relative "relationship_import/relationship_metrics_csv"

metrics_path = File.expand_path "../relationship_import/data/metrics.csv", __FILE__
answers_path = File.expand_path "../relationship_import/data/answers.csv", __FILE__

Card::Auth.current_id = Card.fetch_id("Philipp Kuehl")

RelationshipMetricsCSV.new(metrics_path).import!
RelationshipAnswersCSV.new(answers_path).import!


