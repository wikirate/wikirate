class CSVImport
  def initialize path
    raise Error, "file does not exist: #{path}" unless File.exists? path
    @rows = CSV.read card.csv_path
    @headers = rows.shift
    map_headers
  end

  def headers
    []
  end

  def import!
    each_row do |row|
      process_row row
    end
  end

  private

  def map_headers
    @col_map = {}
    headers.each do |key|
      index = @headers.index key.to_s
      raise Error, "column #{key} is missing" unless index
      @col_map[key] = index
    end
  end

  def row_to_hash row
    @col_map.each_with_object({}) do |(k, v), h|
      h[k] = row[v]
    end
  end

  def each_row
    @rows.each do |row|
      yield row_to_hash(row)
    end
  end
end

class RelationshipMetricCSV < CSVImport
  def headers
    [:designer, :title, :inverse, :value_type, :options, :unit]
  end

  def process_row row
    rm = RelationshipMetric.new row
    rm.create
    rm.create_inverse
  end
end

class RelationshipMetricAnswersCSV
  def headers
    []
  end

  def process_row row
    RelationshipMetricAnswer.new(row).create
  end
end
