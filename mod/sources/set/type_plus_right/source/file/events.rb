
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

event :normalize_html_file, before: :write_identifier, on: :save, when: :html_file? do
  if remote_file_url # CarrierWave magic
    convert_to_pdf
  else
    errors.add :file, "HTML Sources must be downloaded from URLS"
  end
end

def unfilled?
  !remote_file_url && super
end

def accepted_mime_type?
  file.content_type.in? ACCEPTED_MIME_TYPES
end

def convert_to_pdf
  # Rails.logger.info "generating pdf"
  pdf_from_url remote_file_url do |pdf_file|
    self.file = pdf_file
  end
rescue StandardError => e
  errors.add :conversion, "failed to convert HTML source to pdf #{e.message}"
end

def pdf_from_url url
  kit = PDFKit.new url
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    kit.to_file path
    yield ::File.open path
  end
end

# this is cached so that it continues to return true even after the file
# is converted to a pdf.
def html_file?
  file&.content_type == "text/html"
end
