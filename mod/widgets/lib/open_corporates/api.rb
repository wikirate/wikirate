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

      # The OC API returns an array with a structure like this:
      #  "results":{
      #     "industry_code_scheme":{
      #        "id":"isic_4","name":"UN ISIC Rev 4",
      #        "url":"http://unstats.un.org/unsd/cr/registry/isic-4.asp",
      #        "industry_codes":[
      #          {"industry_code":{
      #              "code":"A","description":"Agriculture, forestry and fishing",
      #              "uid":"isic_4-A"}},
      #          {"industry_code":{
      #              "code":"01","description":"Crop and animal production",
      #          ....
      # This method returns an array with a hash for each industry codes
      # @return [Array<Hash>] each industry code has a code, a description and a uid key
      #   Example:
      #       :code=>"855",
      #       :description=>"Educational support activities",
      #       :uid=>"isic_4-855"
      def fetch_industry_codes code_scheme="isic_4"
        fetch_items(:industry_codes, code_scheme,
                    collection_selector: [:results, :industry_code_scheme,
                                          :industry_codes],
                    item_selector: :industry_code).each(&:symbolize_keys!)
      end

      # @example
      #  fetch_json :companies, us_ca, 3234234, sparse: true
      # @return the full json response converted to a hash
      def fetch *query_args
        JSON.parse json_response(*query_args)
      end

      def fetch_items *query_args, collection_selector:, item_selector: nil
        collection_selector = Array.wrap(collection_selector).map(&:to_s)
        result = pick_nested_item(*collection_selector) { fetch(*query_args) }
        return result unless item_selector
        item_selector = Array.wrap(item_selector).map(&:to_s)
        result.map do |item|
          item.dig(*item_selector)
        end
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
        e.io.try(:string) || e.io.try(:read) || raise(e)
      rescue SocketError => _e
        raise APIError, "service temporarily not available"
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

  class APIError < Card::UserError
  end
end
