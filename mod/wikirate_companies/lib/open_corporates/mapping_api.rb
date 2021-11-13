module OpenCorporates
  class MappingApi
    HOST = "easie.iti.gr".freeze
    PATH = "/oc_company_mapping".freeze
    REQUIRED_RESPONSE_FIELDS =
      %w[company_number jurisdiction_code incorporation_jurisdiction_code].freeze

    class << self
      # @return [Hash]
      # @param opts wikipedia_url or
      def fetch_oc_company_number opts
        pick_nested_item do
          fetch "getMappedCompany", opts
        end
      end

      def fetch *query_args
        JSON.parse json_response(*query_args)
      rescue StandardError
        nil
      end

      private

      def pick_nested_item
        return unless (response = yield)
        check_response_format response
        OpenStruct.new company_number: response["company_number"],
                       incorporation_jurisdiction_code: response["incorporation_jurisdiction_code"],
                       jurisdiction_code: response["jurisdiction_code"]
      end

      def check_response_format response
        unless response.is_a?(Hash)
          raise ApiError, "unexpected format, expected a hash but got #{response}"
        end
        REQUIRED_RESPONSE_FIELDS.each do |key|
          unless response.key? key
            raise ApiError, "unexpected format, expected key '#{key}' in #{response}"
          end
        end
      end

      def json_response *query_args
        query_uri(*query_args).read
      rescue OpenURI::HTTPError => e
        e.io.try(:string) || e.io.try(:read) || raise(e)
      rescue SocketError => _e
        raise ApiError, "service temporarily not available"
      rescue StandardError => e
        raise ApiError, "OC JSON response error: #{e.message}"
      end

      def query_uri *query_args
        params = query_args.last.is_a?(Hash) ? query_args.pop : {}
        URI::HTTP.build host: HOST,
                        path: [PATH, query_args].compact.join("/"),
                        query: params.to_query
      end
    end
  end

  class ApiError < Card::Error::UserError
  end
end
