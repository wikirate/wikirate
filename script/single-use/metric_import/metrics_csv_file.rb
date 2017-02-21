require_relative "../../csv_import/csv_file"
require_relative "metric_csv_row"

class MetricsCSVFile < CSVFile
  @columns = [:metric_designer, :metric_title, :question, :about, :methodology, :topics, :value_type, :research_policy]

  def process_row row
    MetricCSVRow.new(row).create
  end
end
