include_set Abstract::Pdfjs
include_set Abstract::Tabs

EXCEL_MIME_TYPES = %w[
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

CSV_MIME_TYPES = %w[
  text/csv
  application/csv
].freeze

ACCEPTED_MIME_TYPES = (%w[
  text/plain
  text/html
  application/pdf
] + EXCEL_MIME_TYPES + CSV_MIME_TYPES).freeze

CONVERT_FOR_PREVIEW = (EXCEL_MIME_TYPES + CSV_MIME_TYPES).freeze

def file_changed?
  !db_content_before_act.empty?
end

def preview_card?
  file.content_type.in? CONVERT_FOR_PREVIEW
end
