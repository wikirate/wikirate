require_relative "../.."
require_relative "relationship_metric"

class RelationshipMetricsCSVFile < CSVFile
  @columns = [:designer, :title, :inverse, :value_type, :value_options, :unit]

  def process_row row
    rm = RelationshipMetricCSVRow.new row
    rm.create
    rm.create_inverse
  end
end
