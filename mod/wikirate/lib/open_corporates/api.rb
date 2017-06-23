module OpenCorporates
  class API
    HOST = "api.opencorporates.com"
    OC_API_VERSION = "0.4"

    class << self
      # @example
      #  fetch_json :companies, us_ca, 3234234, sparse: true
      # @return the json response converted to a hash
      def fetch *query_args
        JSON.parse json_response(*query_args)
      end

      private

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
end
