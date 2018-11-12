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

event :normalize_file, :prepare_to_validate, on: :save do
  normalize_html_file if html_file?
  unless accepted_mime_type?
    errors.add "unaccepted MIME type: #{file.content_type}"
  end
end

event :block_file_changing, after: :write_identifier, on: :update, changed: :content,
      when: :file_changed? do
  errors.add :file, "is not allowed to be changed."
end

def accepted_mime_type?
  file.content_type.in? ACCEPTED_MIME_TYPES
end

def normalize_html_file
  if remote_file_url
    convert_to_pdf
  else
    errors.add :file, "HTML Sources must be downloaded from URLS"
  end
end

def convert_to_pdf
  puts "generating pdf"
  pdf_from_url remote_file_url do |pdf_file|
    self.file = pdf_file
  end
rescue StandardError => e
  errors.add :conversion, "failed to convert HTML source to pdf #{e.message}"
end

def pdf_from_url url
  kit = PDFKit.new url # , "load-error-handling" => "ignore"
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    kit.to_file path
    yield ::File.open path
  end
end

def html_file?
  file&.content_type == "text/html"
end
