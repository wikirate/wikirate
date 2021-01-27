require "timeout"

DOWNLOAD_MAX_SECONDS = 10
CONVERSION_MAX_SECONDS = 30

event :add_source_link, :prepare_to_validate, on: :save, when: :remote_file_url do
  left.add_subfield :wikirate_link, content: remote_file_url
end

# CarrierWave.configure do |config|
#   config.ignore_download_errors = false
# end

event :validate_source_file, :validate, on: :save, changed: :content do
  if file_download_error # CarrierWave magic
    errors.add :download, file_download_error.message
  elsif !accepted_mime_type?
    errors.add :mime, "unaccepted MIME type: #{file.content_type}"
  end
end

event :block_file_changing, after: :write_identifier, on: :update, changed: :content,
                            when: :file_changed? do
  errors.add :file, "is not allowed to be changed." unless Card::Auth.always_ok?
end

event :normalize_html_file, after: :validate_source_file, on: :save, when: :html_file? do
  if remote_file_url # CarrierWave magic
    convert_to_pdf
  else
    errors.add :file, "HTML Sources must be downloaded from URLS"
  end
end

# otherwise download errors that occur when assigning remote_file_url
# will prevent subfield from being recognized as present. that screws up error tracking.
def unfilled?
  !remote_file_url && super
end

def accepted_mime_type?
  file.content_type.in? ACCEPTED_MIME_TYPES
end

def convert_to_pdf
  # Rails.logger.info "generating pdf"
  converting_to_tmp_pdf do |pdf_file|
    self.file = pdf_file
  end
rescue StandardError => e
  msg = "failed to convert HTML to pdf"
  Rails.logger.info "#{msg}: #{e.message}"
  raise SourceConversionError, msg
end

def converting_to_tmp_pdf
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    pdf_from_url path
    yield ::File.open(path)
  end
end

def pdf_from_url path
  Timeout.timeout(CONVERSION_MAX_SECONDS) do
    kit = PDFKit.new remote_file_url, "load-error-handling" => "ignore",
                                      "load-media-error-handling" => "ignore"
    kit.to_file path
  end
end

def html_file?
  file&.content_type == "text/html"
end
