class OCCompany
  def initialize jurisdiction_code, company_number
    @jurisdiction_code = jurisdiction_code
    @company_number = company_number
    fetch_data
  end

  delegate :name, :jurisdiction_code, :company_type, :status, to: :data

  def previous_names
    @data.previous_names.map do |details|
      details["company_name"]
    end
  end

  def registered_address
    @data.registered_address_in_full
  end

  def incorporation_date
    @inc_date ||= Date.parse data.incorporation_date
  end

  def url
    @data.opencorporates_url
  end

  private

  def fetch_data
    @response = OCApi.fetch_json :companies, @jurisdiction_code, @company_number,
                             sparse: true
    validate_json
    @data = OpenStruct.new @json["results"]["company"]
  end

  def validate_json
    if @response["error"]
      raise ArgumentError,
            "couldn't receive open corporates entry: #{@response["error"]["message"]}"
    end
    return if @response["results"].is_a?(Hash) && @response["results"]["company"].is_a?(Hash)
    raise StandardError, "open corporates returned unexpected format for #{oc_url}"
  end
end
