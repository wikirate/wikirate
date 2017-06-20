class OCCompany
  BASE_URL = "https://api.opencorporates.com/v0.4/companies"

  def initialize jurisdiction_code, company_number
    @jurisdiction_code = jurisdiction_code
    @company_number = company_number
    @json = fetch_json
    validate_json
    @json = @json["results"]["company"]
  end

  def name
    get "name"
  end

  def previous_names
    get("previous_names").map do |details|
      details["company_name"]
    end
  end

  def jurisdiction_code
    get "jurisdiction_code"
  end

  def registered_address
    get "registered_address_in_full"
  end

  def incorporation_date
    @date ||= Date.parse get("incorporation_date")
  end

  def company_type
    get "company_type"
  end

  def status
    get "current_status"
  end

  def url
    get "opencorporates_url"
  end

  private

  def get key
    @json[key.to_s]
  end

  def fetch_json
    JSON.parse open(fetch_url).read
  end

  def fetch_url
    "#{BASE_URL}/#{oc_id}?sparse=true"
  end

  # identifier used by OC's api to get a single company entry
  def oc_id
    "#{@jurisdiction}/#{@company_number}"
  end

  def validate_json
    if @json["error"]
      raise ArgumentError,
            "couldn't receive open corporates entry: #{@json["error"]["message"]}"
    end
    return if @json["results"].is_a?(Hash) && @json["results"]["company"].is_a?(Hash)
    raise StandardError, "open corporates returned unexpected format for #{fetch_url}"
  end
end
