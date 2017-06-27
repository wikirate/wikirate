module OpenCorporates
  #
  class API
    HOST = "api.opencorporates.com".freeze
    OC_API_VERSION = "0.4".freeze

    class << self
      # @return [Hash]
      def fetch_companies jurisdiction_code, company_number, opts={}
        pick_nested_item "results", "company" do
          fetch :companies, jurisdiction_code, company_number, opts
        end
      end

      # The OC API returns an array with a structure like this:
      #  [ { "jurisdiction" => { "code"=>"ad", "name"=>"Andorra",
      #                          "country"=>"Andorra", "full_name"=>"Andorra" } },
      #       ...
      #  ]
      # This method removes the additional hash level with the "jurisdiction" key.
      # @return [Array<Hash>]
      def fetch_jurisdictions
        result =
          pick_nested_item "results", "jurisdictions" do
            fetch :jurisdictions
          end
        result.map do |jur|
          jur["jurisdiction"]
        end
      end

      # @example
      #  fetch_json :companies, us_ca, 3234234, sparse: true
      # @return the full json response converted to a hash
      def fetch *query_args
        JSON.parse json_response(*query_args)
      rescue OpenURI::HTTPError => e
        error = JSON.parse e.io.string
        raise APIError, error["error"]["message"]
      rescue StandardError => _e
        raise APIError, "service temporarily not available"
      end

      private

      def pick_nested_item *structure
        response = yield
        raise APIError, response["error"]["message"] if response.key?("error")
        structure.each do |key|
          unless response.is_a?(Hash) && response.key?(key)
            raise APIError, "unexpected format"
          end
          response = response[key]
        end
        response
      end

      def json_response *query_args
        query_uri(*query_args).read
      rescue OpenURI::HTTPError => e
        e.io.string
      end

      def query_uri *query_args
        params = query_args.last.is_a?(Hash) ? query_args.pop : {}
        params[:api_token] = api_key if api_key
        URI::HTTPS.build host: HOST,
                         path: ["/v#{OC_API_VERSION}", query_args].join("/"),
                         query: params.to_query
      end

      def api_key
        Card.config.try :opencorporates_key
      end
    end
  end

  class APIError < StandardError
  end
end
