class OpenCorporates
  class API
    OC_API_VERSION = "0.4"
    OC_API_BASE_URL = "https://api.opencorporates.com/v#{OC_API_VERSION}"

    class << self
      # @example
      #  fetch_json :companies, us_ca, 3234234, sparse: true
      def fetch_json *query_args
        params = query_args.last.is_a?(Hash) ? query_args.pop.to_param : {}
        params[:api_key] = api_key if api_key
        oc_url = [OC_API_BASE_URL, query_args].join "/"
        oc_url << "?#{params}" if params
        JSON.parse open(oc_url).read
      end

      def api_key
        Card.config.try :open_corporates_api_key
      end
    end
  end
end
