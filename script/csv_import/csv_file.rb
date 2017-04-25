require_relative "csv_row"

# Use CSVFile to describe the structure of a csv file and import its content
class CSVFile
  def initialize path, row_class
    raise StandardError, "file does not exist: #{path}" unless File.exist? path
    raise ArgumentError, "#{row_class} must inherit from CSVRow" unless row_class.is_a? CSVRow
    @row_class = row_class
    @rows = CSV.read path
    @headers = @rows.shift.map { |h| h.downcase.tr(" ", "_") }
    map_headers
  end

  def import!
    each_row do |row|
      process_row row
    end
  end

  private

  def process_row row
    @row_class.new(row).create
  end

  def each_row
    @rows.each do |row|
      next if row.compact.empty?
      yield row_to_hash(row)
    end
  end

  def map_headers
    @col_map = {}
    @row_class.columns.each do |key|
      index = @headers.index key.to_s
      raise StandardError, "column #{key} is missing" unless index
      @col_map[key] = index
    end
  end

  def row_to_hash row
    @col_map.each_with_object({}) do |(k, v), h|
      h[k] = row[v].strip if row[v].present?
    end
  end
end
