include_set Abstract::CompanyExcerpt

def excerpt_host
  "openapparel.org"
end

def excerpt_path
  "/api/facilities/#{content}/"
end

def excerpt_json query={}
  super({ format: :json }.merge(query))
end

def excerpt_link_url
  excerpt_uri
end

def excerpt_authorization
  { "Authorization" => "Token #{api_key}" }
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
      coordinates: excerpt_coordinates.compact.join(", ")
    }
  end

  def excerpt_coordinates
    Array.wrap @excerpt_result.geometry&.dig("coordinates")
  end
end
