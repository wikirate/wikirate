module OpenCorporates
  class API
    VERSION = "0.4"
    BASE_URL = "https://api.opencorporates.com/v#{VERSION}"

    class << self
      # @example
      #  fetch_json :companies, us_ca, 3234234, sparse: true
      # @return the json response converted to a hash
      def fetch *query_args
        json_response = open(query_url(*query_args)).read
        JSON.parse json_response
      end

      def query_url *query_args
        params = query_args.last.is_a?(Hash) ? query_args.pop : {}
        params[:api_key] = api_key if api_key
        oc_url = [BASE_URL, query_args].join "/"
        oc_url << "?#{params.to_param}" if params
      end

      def api_key
        Card.config.try :opencorporates_key
      end
    end
  end
end
