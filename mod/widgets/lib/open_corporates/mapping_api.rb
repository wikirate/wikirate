module OpenCorporates
  class MappingAPI
    HOST = "easie.iti.gr".freeze
    PATH = "/oc_company_mapping".freeze
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
      end

      private

      def pick_nested_item
        response = yield
        unless response.is_a?(Hash) &&
          response["oc_company_number"].is_a?(Array) &&
          response["oc_jurisdiction_code_of_incorporation"].is_a?(Array)
          raise APIError, "unexpected format"
        end
        OpenStruct.new company_number: response["oc_company_number"].first,
                             jurisdiction_code_of_incorporation: response["oc_jurisdiction_code_of_incorporation"].first
      end

      def json_response *query_args
        query_uri(*query_args).read
      rescue OpenURI::HTTPError => e
        e.io.try(:string) || e.io.try(:read) || raise(e)
      rescue SocketError => _e
        raise APIError, "service temporarily not available"
      end

      def query_uri *query_args
        params = query_args.last.is_a?(Hash) ? query_args.pop : {}
        URI::HTTP.build host: HOST,
                         path: [PATH, query_args].compact.join("/"),
                         query: params.to_query
      end
    end
  end

  class APIError < StandardError
  end
end
