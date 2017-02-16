require_relative "csv_import"
require_relative "relationship_metric"

class RelationshipMetricsCSV < CSVImport
  @columns = [:designer, :title, :inverse, :value_type, :value_options, :unit]

  def process_row row
    rm = RelationshipMetric.new row
    rm.create
    rm.create_inverse
  end
end
