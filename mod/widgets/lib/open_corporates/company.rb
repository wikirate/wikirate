module OpenCorporates
  class Company
    attr_reader :properties, :error

    def initialize jurisdiction_code, company_number, sparse=true
      @jurisdiction_code = jurisdiction_code
      @company_number = company_number
      @sparse = sparse
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
      unless @jurisdiction_code.match?(/^\w+$/)
        fail "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def validate_company_number
      return fail("no company number") unless @company_number
      unless @company_number.is_a?(Integer) || @company_number.match(/^[\d\w-]+$/)
        fail "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def fetch_properties
      api_response
      @properties = OpenStruct.new api_response
    rescue APIError => e
      msg = if e.message == "unexpected format"
              "open corporates returned unexpected format for "\
              "#{@jurisdiction_code}/#{@company_number}"
            else
              "couldn't receive open corporates entry: #{e.message}"
            end
      fail msg
    ensure
      @properties ||= OpenStruct.new
    end

    def api_response
      opts = {}
      opts[:sparse] = true if @sparse
      @api_response ||=
        ::OpenCorporates::API.fetch_companies @jurisdiction_code, @company_number, opts

    end
  end
end
