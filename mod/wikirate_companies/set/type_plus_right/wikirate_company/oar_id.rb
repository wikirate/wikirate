include_set Abstract::CompanyExcerpt

OPENSTREETMAP_URL =
  "https://www.openstreetmap.org/?mlon=%<longitude>s&mlat=%<latitude>s&zoom=25".freeze

def excerpt_host
  "opensupplyhub.org"
end

def excerpt_path
  "/api/facilities/#{content}/"
end

def excerpt_json query={}
  super({ format: :json }.merge(query))
end

def excerpt_link_url
  protocol_class.build host: excerpt_host, path: "/facilities/#{content}"
end

def excerpt_authorization
  { "Authorization" => "Token #{api_key}" }
end

def api_key
  Card.config.try(:oar_id_api_key) || raise("OAR API key not found")
end

format :html do
  def excerpt_body
    excerpt_table
  end

  def excerpt_table_hash
    prop = @excerpt_result.properties || {}
    {
      name: prop["name"],
      id: @excerpt_result.id,
      country: prop["country_code"],
      address: prop["address"],
      coordinates: coordinates_link
    }
  end

  def coordinates_link
    link_to coordinates.join(", "), href: openstreetmap_url if coordinates.present?
  end

  def openstreetmap_url
    format OPENSTREETMAP_URL, longitude: coordinates.first, latitude: coordinates.last
  end

  def coordinates
    @coordinates ||= Array.wrap(@excerpt_result.geometry&.dig("coordinates"))
  end
end
