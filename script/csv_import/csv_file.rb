require_relative "csv_row"

# Use CSVFile to describe the structure of a csv file and import its content
class CSVFile
  def initialize path, row_class, col_sep: ","
    raise StandardError, "file does not exist: #{path}" unless File.exist? path
    raise ArgumentError, "#{row_class} must inherit from CSVRow" unless row_class < CSVRow
    @row_class = row_class
    @rows = CSV.read path, col_sep: col_sep
    @headers = @rows.shift.map { |h| h.downcase.tr(" ", "_") }
    map_headers
  end

  # @param error_policy [:fail, :skip, :report]
  def import error_policy: :fail, user: nil
    with_user user do
      each_row do |row, index|
        process_row row, index, error_policy
      end
    end
  end

  private

  def with_user user
    if user
      Card::Auth.with(user) { yield }
    elsif Card::Auth.signed_in?
      yield
    else
      raise StandardError, "can't import as anonymous"
    end
  end

  def process_row row, index, error_policy=:fail
    csv_row = @row_class.new(row, index)
    csv_row.execute_import
  rescue ImportError => e
    case error_policy
    when :fail   then raise e
    when :report then puts csv_row.errors.join("\n")
    when :skip   then nil
    end
  end

  def each_row
    @rows.each.with_index do |row, i|
      next if row.compact.empty?
      yield row_to_hash(row), i
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
      h[k] = row[v]
      h[k] &&= h[k].strip
    end
  end
end
