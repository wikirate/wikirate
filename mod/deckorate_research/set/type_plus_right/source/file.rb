include_set Abstract::Pdfjs
include_set Abstract::Tabs

assign_type :file

SPREADSHEET_MIME_TYPES = %w[
  text/csv
  application/csv
  application/vnd.ms-excel
  application/msexcel
  application/x-msexcel
  application/x-ms-excel
  application/x-excel
  application/x-dos_ms_excel
  application/xls
  application/x-xls
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
].freeze

ACCEPTED_MIME_TYPES = (SPREADSHEET_MIME_TYPES + %w[
  text/plain
  text/html
  application/pdf
  application/xml
  text/xml
  application/xhtml+xml
  application/json
  application/ld+json
  text/json
  text/x-json
]).freeze


def file_changed?
  !db_content_before_act.empty?
end

def spreadsheet_type?
  file.content_type.in? CONVERT_FOR_PREVIEW
end
