module OpenCorporates
  class Company
    attr_reader :properties

    def initialize jurisdiction_code, company_number
      @jurisdiction_code = jurisdiction_code
      @company_number = company_number
      validate_jurisdiction_code
      validate_company_number
      fetch_properties unless @errors.present?
    end

    def valid?
      @error.present?
    end

    delegate :name, :jurisdiction_code, :company_type, :opencorporates_url,
             to: :properties

    def previous_names
      return unless properties.previous_names.is_a? Array
      properties.previous_names.map do |details|
        details["company_name"]
      end
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

    def validate_jurisdiction_code
      unless @jurisdiction_code.match(/^\w+$/)
        @error = "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def validate_company_number
      unless @company_number.is_a?(Integer) || @company_number.match(/^[\d\w]+$/)
        @error = "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def fetch_properties
      validate_response
      return if @error.present?
      @properties = OpenStruct.new api_response["results"]["company"]
    end

    def validate_response
      @error =
        if api_response["error"]
          "couldn't receive open corporates entry: "\
          "#{api_response["error"]["message"]}"
        elsif !api_response["results"].is_a?(Hash) ||
          !api_response["results"]["company"].is_a?(Hash)
          "open corporates returned unexpected format for "\
          "#{@jurisdiction_code}/#{@company_number}"
        end
    end

    def api_response
      @api_response ||=
        API.fetch :companies, @jurisdiction_code, @company_number, sparse: true
    end
  end
end
