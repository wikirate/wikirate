def download_and_add_file
  return unless downloadable?
  after_download_success do
    change_source_type_to_file
  end
rescue StandardError # if open raises errors just treat the source as a normal source
  Rails.logger.info "failed to get the file from link"
end

def after_download_success
  file_field =
    add_subfield :file, remote_file_url: file_url, type_id: FileID, content: "dummy"
  file_field.director.catch_up_to_stage :validate
  if file_field.errors.any?
    remove_subfield :file
    return
  end
  true.tab { yield }
end

def downloadable?
  file_link? && url.present? && within_file_size_limit?
end

def file_url
  url.include?("%") ? url : Addressable::URI.escape(url)
end

def change_source_type_to_file
  source_type = subfield(:source_type)
  source_type.content = "[[#{:file.cardname}]]"
  remove_subfield :wikirate_link
  reset_patterns
  include_set_modules
end

def file_link?
  file_type.present? && !file_type.start_with?("text/html", "image/", "*/*")
end

def within_file_size_limit?
  file_size.to_i <= max_size.megabytes
end

def file_type
  @file_type ||= header[/.*Content-Type: (.*)\r\n/, 1] || ""
end

def header
  @header ||= fetch_http_header
end

def fetch_http_header
  curl = Curl::Easy.new url
  curl.follow_location = true
  curl.max_redirects = 5
  curl.http_head
  curl.header_str
rescue Curl::Easy::Error, Curl::Err::CurlError => error
  Rails.logger.info "Fail to extract header from the #{url}, #{error.message}"
  ""
end

def file_size
  @file_size ||= header[/.*Content-Length: (.*)\r\n/, 1].to_i
end

def max_size
  # prevent from showing file too big while users are adding a link source
  (max = Card["*upload max"]) ? max.db_content.to_i : 5
end
