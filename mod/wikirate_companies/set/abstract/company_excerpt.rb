def excerpt_json query={}
  JSON.parse excerpt_response(query)
rescue StandardError
  {}
end

def excerpt_response query={}
  excerpt_uri(query).read excerpt_authorization
end

def protocol_class
  URI::HTTPS
end

def excerpt_authorization
  {}
end

def excerpt_uri query={}
  protocol_class.build(
    host: excerpt_host,
    path: excerpt_path,
    query: excerpt_query(query)
  )
end

def excerpt_query query={}
  query.to_query
end

def excerpt_host
  raise Error, "excerpt_host not overridden"
end

def excerpt_path
  raise Error, "excerpt_path not overridden"
end

def excerpt_link_url
  raise Error, "excerpt_link not overridden"
end

format :html do
  delegate :excerpt_link_url, :excerpt_json, to: :card

  view :standard_core, template: :haml

  view :core, async: true do
    if excerpt_result
      render_standard_core
    elsif @excerpt_error_message
      excerpt_error
    else
      ""
    end
  end

  def excerpt_result
    rescuing_excerpt_error do
      json = excerpt_json
      return unless json.present?

      @excerpt_result = OpenStruct.new json
    end
  end

  def excerpt_body
    raise Error, "excerpt_body not overridden"
  end

  def excerpt_link_text
    card.excerpt_host
  end

  def excerpt_table
    table excerpt_table_rows, class: "excerpt-table table-borderless table-condensed"
  end

  def excerpt_table_rows
    excerpt_table_hash.to_a
  end

  def excerpt_error
    alert(:warning, true) { @excerpt_error_message }
  end

  def excerpt_table_hash
    raise Error, "excerpt_table_hash not overridden"
  end

  def rescuing_excerpt_error
    yield
  rescue StandardError => error
    @excerpt_error_message = error.message
    nil
  end
end
