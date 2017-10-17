#! no set module

# An ImportRow object generates the html for a row in the import table.
# It needs a format with `column_keys` and a {CSVRow} object.
# For each value in column_keys in generates a cell. It takes the content from the CSVRow
# object if it has data for that key.
# Otherwise it expects a `<missing_key>_field` method to produce the cell content.
class TableRow
  attr_reader :match_type, :csv_row, :format

  delegate :row_index, :status, to: :csv_row
  delegate  :corrections_input_name, to: :format

  # @param csv_row [CSVRow] a CSVRow object
  # @param format the format of an import file. It has to respond to `column_keys`.
  #        It is also used to generate form elements.
  def initialize csv_row, format
    @csv_row = csv_row
    @format = format
  end

  def valid?
    !@csv_row.errors?
  end

  def imported?
    @format.already_imported? @csv_row.row_index
  end

  # The return value is supposed to be passed to the table helper method.
  # @return [Hash] the :content value is an array with the text/html for each cell
  def render
    res = { content: fields, data: { csv_row_index: @csv_row.row_index } }
    res[:class] = "table-danger" unless valid?
    res
  end


  # def render
  #   super.merge class: "table-#{row_context}"
  # end
  #
  private

  # @return [Array] values for every cell in the table row
  def fields
    @format.column_keys.map do |key|
      send "#{key}_field"
    end
  end

  def checked?
    true
  end

  def extra_data
    {}
  end

  def corrections
    {}
  end

  def row_index_field
    @csv_row.row_index + 1
  end

  def checkbox_field
    # disable if data is invalid
     @format.check_box_tag("import_rows[#{@csv_row.row_index}]", true, valid? && checked?,
                           disabled: !valid?) + extra_data_tags.html_safe
  end

  def extra_data_tags
    extra_data.each_with_object([]) do |(k, v), a|
      a << @format.hidden_field_tag(extra_data_input_name(k), v)
    end.join "\n"
  end

  def correction_tag key, value, index=@csv_row.row_index
    name = extra_data_input_name(index, :corrections, key)
    @format.hidden_field_tag name, value
  end

  def extra_data_input_name *subfields
    @format.extra_data_input_name @csv_row.row_index, *subfields
  end

  def corrections_input_name key
    @format.corrections_input_name @csv_row.row_index, key
  end

  def method_missing method, *_args, &_block
    return super unless (field = field_from_method(method))
    @csv_row[field.to_sym]
  end

  def respond_to_missing? method, _include_private=false
    field_method?(method) || super
  end

  def field_from_method method
    method =~ /^(\w+)_field$/ ? $1 : nil
  end

  def field_method? method
    method =~ /^\w+_field$/
  end
end
