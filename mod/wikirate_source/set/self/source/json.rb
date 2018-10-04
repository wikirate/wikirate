
format :json do
  view :metadata do
    url = Card::Env.params[:url] || ""
    MetaData.new(url).to_json
  end

  def valid_content_type? content_type, user_agent
    allow_content_type = ["image/png", "image/jpeg"]
    # for case, "text/html; charset=iso-8859-1"
    allow_content_type.include?(content_type) ||
      content_type.start_with?("text/html", "text/plain") ||
      firefox?(user_agent)
  end

  def valid_x_frame_options? options
    return true unless options
    !options.upcase.include?("DENY") &&
      !options.upcase.include?("SAMEORIGIN")
  end

  def iframable_options url
    # escape space in url, eg,
    # http://www.businessweek.com/articles/2014-10-30/
    # tim-cook-im-proud-to-be-gay#r=most popular
    url.gsub!(/ /, "%20")
    curl = Curl::Easy.new(url)
    curl.follow_location = true
    curl.max_redirects = 5
    curl.http_head
    header_str = curl.header_str
    [header_str[/.*X-Frame-Options: (.*)\r\n/, 1],
     header_str[/.*Content-Type: (.*)\r\n/, 1]]
  end

  def firefox? user_agent
    user_agent ? user_agent =~ /Firefox/ : false
  end

  def iframable? url, user_agent
    return false unless url.present?
    x_frame_options, content_type = iframable_options url
    valid_x_frame_options?(x_frame_options) &&
      valid_content_type?(content_type, user_agent)
  rescue StandardError => error
    Rails.logger.error error.message
    return false
  end

  view :check_iframable do
    user_agent = request ? request.env["HTTP_USER_AGENT"] : nil
    { result: !!iframable?(params[:url], user_agent) }
  end
end