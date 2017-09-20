require_relative "csv_row"

# Use CSVFile to describe the structure of a csv file and import its content
class CSVFile
  # @param headers [true, false, :detect] (false) if true the import raises an error
  #    if the csv file has no or wrong errors
  def initialize path_or_file, row_class, col_sep: ",", encoding: "utf-8", headers: false
    raise ArgumentError, "#{row_class} must inherit from CSVRow" unless row_class < CSVRow
    @row_class = row_class
    @col_sep = col_sep
    @encoding = encoding

    read_csv path_or_file
    if header_row?
      @headers
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

  def read_csv path_or_file
    @rows =
      if path_or_file.respond_to?(:read)
        read_csv_from_file_handle path_or_file
      else
        read_csv_from_path path_or_file
      end
  end

  def read_csv_from_path path
    raise StandardError, "file does not exist: #{path}" unless File.exist? path
    rescue_encoding_error do
      CSV.read path, csv_options
    end
  end

  def read_csv_from_file_handle file
    rescue_encoding_error do
      CSV.parse file.read, csv_options
    end
  end

  def rescue_encoding_error
    yield
  rescue ArgumentError => _e
    # if parsing with utf-8 encoding fails, assume it's iso-8859-1 encoding
    # and convert to utf-8
    with_encoding "iso-8859-1:utf-8" do
      yield
    end
  end

  def csv_options
    { col_sep: @col_sep, encoding: @encoding }
  end

  def with_encoding encoding
    enc = @encoding
    @encoding = encoding
    yield
  ensure
    @encoding = enc
  end

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
  rescue ImportError, InvalidData => e
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
      yield row_to_hash(@rows[index]), index
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

  def reject_headers
    @rows.shift if header_row?
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
