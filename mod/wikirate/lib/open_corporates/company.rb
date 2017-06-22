class OpenCorporates
  class Company
    def initialize jurisdiction_code, company_number
      @jurisdiction_code = jurisdiction_code
      @company_number = company_number
      validate_jurisdiction_code
      validate_company_number
      fetch_data unless @errors.present?
    end

    def valid?
      @error.present?
    end

    delegate :name, :jurisdiction_code, :company_type, :status,
             :opencorporates_url, to: :data

    def previous_names
      @data.previous_names.map do |details|
        details["company_name"]
      end
    end

    def registered_address
      @data.registered_address_in_full
    end

    def incorporation_date
      @inc_date ||= Date.parse @data.incorporation_date
    end

    private

    def validate_jurisdiction_code
      unless @jurisdiction_code.match /\w+/
        @error = "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def validate_company_number
      unless @company_number.is @jurisdiction_code.match /\w+/
        @error = "invalid jurisdiction code: #{@jurisdiction_code}"
      end
    end

    def fetch_data
      validate_response
      return if @error.present?
      @data = OpenStruct.new @json["results"]["company"]
    end

    def validate_response
      @error =
        if api_response["error"]
          "couldn't receive open corporates entry: "\
          "#{api_response["error"]["message"]}"
        elsif !api_response["results"].is_a?(Hash) ||
          !api_response["results"]["company"].is_a?(Hash)
          "open corporates returned unexpected format for #{oc_url}"
        end
    end

    def api_response
      @api_response ||=
        API.fetch_json :companies, @jurisdiction_code, @company_number,
                       sparse: true
    end
  end
end
