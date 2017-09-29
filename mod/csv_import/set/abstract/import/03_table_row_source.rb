#! no set module

#require_relative "table_row_with_company_mapping"

# A {TableRow} variant with an extra field for the source title.
class TableRowSource < TableRowWithCompanyMapping
  def title_field
    default_title = csv_row[:title] ||
        "#{@match.suggestion}-#{csv_row[:report_type]}-#{csv_row[:year]}"
    @format.text_field_tag(input_name(:extra_data, :corrections, :title), default_title,
                           class: "min-width-300")
  end
end
