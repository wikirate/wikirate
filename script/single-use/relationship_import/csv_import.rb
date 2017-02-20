class CSVImport
  @columns = []

  def initialize path
    raise StandardError, "file does not exist: #{path}" unless File.exist? path
    @rows = CSV.read path
    @headers = @rows.shift.map { |h| h.downcase.tr(" ", "_") }
    map_headers
  end

  class << self
    attr_reader :columns
  end

  def import!
    each_row do |row|
      process_row row
    end
  end

  private

  def each_row
    @rows.each do |row|
      next if row.compact.empty?
      yield row_to_hash(row)
    end
  end

  def map_headers
    @col_map = {}
    self.class.columns.each do |key|
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
