class OCApi
  OC_API_VERSION = "0.4"
  OC_API_BASE_URL = "https://api.opencorporates.com/v#{OC_API_VERSION}"

  class << self
    def fetch_json *query_args
      if query_args.last.is_a? Hash
        params = query_args.pop.to_param
      end
      oc_url = [OC_API_BASE_URL, path_parts].join "/"
      oc_url << "?#{params}" if params
      JSON.parse open(oc_url).read
    end
  end
end
