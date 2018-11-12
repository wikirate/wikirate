def file_url
  url.include?("%") ? url : Addressable::URI.escape(url)
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
rescue Curl::Easy::Error => error
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
