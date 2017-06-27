module OpenCorporates
  class Company
    attr_reader :properties, :error

    def initialize jurisdiction_code, company_number
      @jurisdiction_code = jurisdiction_code
      @company_number = company_number
      validate_jurisdiction_code
      validate_company_number
      fetch_properties
    end

    def valid?
      @error.blank?
    end

    delegate :name, :jurisdiction_code, :company_type, :opencorporates_url,
             to: :properties

    def previous_names
      return unless properties.previous_names.is_a? Array
      properties.previous_names.map do |details|
        details["company_name"]
      end.join ", "
    end

    def registered_address
      properties.registered_address_in_full
    end

    def status
      properties.current_status
    end

    def incorporation_date
      @inc_date ||= (date = properties.incorporation_date) && Date.parse(date)
    end

    private

    def fail msg
      @error = msg
    end

    def validate_jurisdiction_code
      return fail("no jurisdiction code") unless @jurisdiction_code
      unless @jurisdiction_code =~ /^\w+$/
        fail "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def validate_company_number
      return fail("no company number") unless @company_number
      unless @company_number.is_a?(Integer) || @company_number.match(/^[\d\w]+$/)
        fail "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def fetch_properties
      api_response
      return unless valid?
      validate_response
      return unless valid?
      @properties = OpenStruct.new api_response["results"]["company"]
    ensure
      @properties ||= OpenStruct.new
    end

    def validate_response
      if api_response["error"]
        fail "couldn't receive open corporates entry: "\
             "#{api_response['error']['message']}"
      elsif !response_has_expected_structure?
        fail "open corporates returned unexpected format for "\
             "#{@jurisdiction_code}/#{@company_number}"
      end
    end

    def response_has_expected_structure?
      api_response["results"].is_a?(Hash) &&
        api_response["results"]["company"].is_a?(Hash)
    end

    def api_response
      @api_response ||=
        ::OpenCorporates::API.fetch :companies, @jurisdiction_code, @company_number,
                                    sparse: true
    rescue OpenURI::HTTPError => e
      JSON.parse e.io.string
    rescue StandardError => _e
      fail "service temporarily not available"
    end
  end
end
