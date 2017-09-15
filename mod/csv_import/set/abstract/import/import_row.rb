#! no set module

class ImportRow
  # @param data [Hash] { column_name => column_value }
  attr_reader :match_type

  def initialize data, col_names, index, format
    @data = data
    @csv_row_index = index
    @match = match_company
    @col_names = col_names
    @wikirate_company, @match_type = @match.match
    @company = @match.suggestion
  end

  def render
    finalize_row
    content = @col_names.map { |key| @data[key].to_s }
    { content: content,
      class: "table-#{row_context}",
      data: { csv_row_index: @csv_row_index } }
  end

  private

  def finalize_row
    @data[:row] = @csv_row_index + 1
    @data[:checkbox] = import_checkbox
    @data[:correction] = data_correction
  end

  def import_checkbox
     key_hash = @data.deep_dup
     key_hash[:company] = @match.suggestion
     checked = !@match.none?

     format.check_box_tag "import_data[]", key_hash.to_json, checked
  end

  def data_correction
    return "" if @match.exact?
    company_correction_field
  end

  def company_correction_field
    format.text_field_tag("corrected_company_name[#{@csv_row_index + 1}]", "",
                   class: "company_autocomplete")
  end

  def row_context
    case @match_type
    when :partial then "warning"
    when :exact   then "success"
    when :none    then "danger"
    when :alias   then "info"
    end
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def match_company
    name = @data[:file_company]
    @company_matcher ||= {}
    @company_matcher[name] ||= CompanyMatcher.new(name)
  end
end
