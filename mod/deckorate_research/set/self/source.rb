include_set Abstract::SourceSearch
include_set Abstract::CachedCount

recount_trigger :type, :source, on: [:create, :delete] do |_changed_card|
  Card[:source]
end

format :html do
  view :copy_catcher, unknown: true, wrap: :slot, cache: :never do
    url = params[:url]
    return "" unless url && (sources = Card::Source.search_by_url url)&.any?

    haml :copy_catcher, sources: sources
  end
end

format :json do
  view :metadata, perms: :none do
    url = Card::Env.params[:url] || ""
    MetaData.new(url).to_json
  end

  view :check_iframable, perms: :none do
    user_agent = request ? request.env["HTTP_USER_AGENT"] : nil
    { result: iframable?(params[:url], user_agent) }
  end

  def iframable? url, user_agent
    return false unless url.present?

    rescuing_iframe_errors do
      x_frame_options, content_type = iframable_options url
      valid_x_frame_options?(x_frame_options) &&
        valid_content_type?(content_type, user_agent)
    end
  end

  def rescuing_iframe_errors
    yield
  rescue StandardError => error
    handle_iframe_error error
  end

  def handle_iframe_error error
    Rails.logger.error error.message
    false
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
    [header_str[/.*X-Frame-Options: (.*)\r\n/i, 1],
     header_str[/.*Content-Type: (.*)\r\n/i, 1]]
  end

  def firefox? user_agent
    user_agent ? user_agent.match?(/Firefox/) : false
  end
end
