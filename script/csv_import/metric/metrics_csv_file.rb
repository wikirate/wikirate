require_relative "../../csv_file"
require_relative "metric_csv_row"

class MetricsCSVFile < CSVFile
  @columns =
    [:metric_designer, :metric_title, :question, :about, :methodology,
     :topics, :value_type, :research_policy, :metric_type, :report_type]

  def process_row row
    MetricCSVRow.new(row).create
  end
end
