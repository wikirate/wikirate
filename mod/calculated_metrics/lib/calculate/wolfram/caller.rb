class Calculate
  class Wolfram
    # handler for Wolfram api calls
    class Caller
      attr_reader :expression, :errors, :results
      OBJECTS_URL_BASE = "https://www.wolframcloud.com/objects/".freeze

      def initialize expression
        @expression = expression
        @errors = []
      end

      def interpreter
        raise Card::Error::ServerError, "no Wolfram interpreter configured" unless api_key

        "#{OBJECTS_URL_BASE}#{api_key}"
      end

      def api_key
        @api_key ||= Card.config.try :wolfram_api_key
      end

      def run
        return unless response_body

        @results = interpret_response_body
      end

      def response
        @response ||= post_request
      end

      def response_body
        @response_body ||= response.present? && parse_json(:body, response.body)
      end

      def post_request
        uri = URI.parse interpreter
        Net::HTTP.post_form uri, "expr" => expression
      rescue StandardError => e
        log_error "request failed", e.message
      end

      def log_error main, extra=nil
        main = "Wolfram Error: #{main}"
        @errors << main
        Rails.logger.info "#{main}: #{extra}"
        nil
      end

      def interpret_response_body
        success_response || syntax_error_response || error_code_response
      end

      def success_response
        return unless response_body["Success"]

        parse_json :result, response_body["Result"]
      end

      def syntax_error_response
        # Are we sure this is always a syntax error?
        return unless (messages = response_body["MessagesText"])

        messages.unshift "Formula Syntax Error: bad Wolfram syntax"
        messages.each { |message| log_error message }
      end

      def error_code_response
        log_error "#{response_body['errorCode']}: #{response_body['errorDetails']}"
      end

      def parse_json type, json
        JSON.parse json
      rescue JSON::ParserError => e
        log_error "Unexpected #{type} response", "JSON = #{json}\n#{e.message}"
      end
    end
  end
end
