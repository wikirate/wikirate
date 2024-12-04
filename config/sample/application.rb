require File.expand_path("../boot", __FILE__)

require "decko/application"

module Decko
  # Wikirate application object. holds config options
  class Deck < Application
    # Decko inherits Rails configuration options.
    # See http://guides.rubyonrails.org/configuring.html

    # EMAILS
    # emails are off by default if you want to send emails:
    # config.action_mailer.raise_delivery_errors = true
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }
    # config.action_mailer.perform_deliveries = true

    # VIEW CACHING
    # config.view_cache = false

    # config.oar_id_api_key       = ENV["WIKIRATE_OPEN_APPAREL_KEY"]
    # config.opencorporates_key   = ENV["WIKIRATE_OPENCORPORATES_KEY"]
    # config.google_analytics_key = ENV["WIKIRATE_GOOGLE_ANALYTICS_KEY"].split(" ")

    # PAGING   # config.paging_limit = 10

    config.recaptcha_public_key =
      ENV["WIKIRATE_RECAPTCHA_PUBLIC_KEY"] || "6LdhRssSAAAAAFfLt1Wkw43hoaA8RTIgso9-tvtc"
    config.recaptcha_private_key =
      ENV["WIKIRATE_RECAPTCHA_PRIVATE_KEY"] || "6LdhRssSAAAAAGwzl069pJQBdmzCZigm1nV-dmqK"

    # s3config = {
    #   read_only: true,
    #   provider: "fog/aws",
    #   subdirectory: "files",
    #   credentials: {
    #     provider: "AWS",
    #     aws_access_key_id:     ENV["WIKIRATE_AWS_ACCESS_KEY_ID"],
    #     aws_secret_access_key: ENV["WIKIRATE_AWS_SECRET_ACCESS_KEY"],
    #     region: "eu-central-1"
    #   },
    #   attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
    #   public: true
    # }
    #
    # config.file_storage = :cloud
    # config.file_buckets = {
    #   s3_dev_bucket:     s3config.merge(directory: "wikirate-dev"),
    #   s3_staging_bucket: s3config.merge(directory: "wikirate-staging"),
    #   s3_live_bucket:    s3config.merge(directory: "wikirate")
    # }

    # not clear if these are still needed? If so, they should probably be in deckorate
    # code.
    config.action_dispatch.default_headers = {
      "X-Frame-Options" => "ALLOWALL",
      "Access-Control-Allow-Origin" => "*"
    }
  end
end
