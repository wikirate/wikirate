require_relative "csv_row"

# Use CSVFile to describe the structure of a csv file and import its content
class CSVFile
  # @param enforce_headers [Boolean] (true) if true the import raises an error
  #    if the csv file has no or wrong errors
  def initialize path, row_class, col_sep: ",", headers: false
    raise StandardError, "file does not exist: #{path}" unless File.exist? path
    raise ArgumentError, "#{row_class} must inherit from CSVRow" unless row_class < CSVRow
    @row_class = row_class
    @rows = CSV.read path, col_sep: col_sep
    if header_row?
      @headers =
    end
    @headers = @rows.shift.map { |h| h.downcase.tr(" ", "_") }
    enforce_headers ? map_headers : reject_headers
  end

  # @param error_policy [:fail, :skip, :report]
  def import rows: false, error_policy: :fail, user: nil, corrections: {}
    with_user user do
      each_row(rows) do |row, index|
        process_row row, index, error_policy, corrections || {}
      end
    end
  end

  def each_row rows=nil, &block
    if rows
      selected_rows rows, &block
    else
      all_rows &block
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

  def process_row row, index, error_policy=:fail, corrections={}
    csv_row = @row_class.new(row, index, corrections[index])
    csv_row.execute_import
  rescue ImportError => e
    case error_policy
    when :fail   then raise e
    when :report then puts csv_row.errors.join("\n")
    when :skip   then nil
    end
  end

  def all_rows
    @rows.each.with_index do |row, i|
      next if row.compact.empty?
      yield row_to_hash(row), i
    end
  end

  def selected_rows rows
    rows.each do |index|
      yield row_to_hash @rows[index], index
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

  def reject_header_row import_data
    @rows.shift if includes_header?
    return unless (first_row = import_data.first)
    return unless includes_column_header first_row
    import_data.shift
  end

  def header_row?
    return unless (first_row = @rows.first)
    first_row.all? { |item| item && @row_class.columns.include?(item.downcase.to_sym) }
  end

  def row_to_hash row
    @col_map.each_with_object({}) do |(k, v), h|
      h[k] = row[v]
      h[k] &&= h[k].strip
    end
  end
end
