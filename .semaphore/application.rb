require File.expand_path('../boot', __FILE__)

require 'decko/all'

module Wikirate
  class Application < Decko::Application

    # Decko inherits Rails configuration options.  See http://guides.rubyonrails.org/configuring.html

    config.recaptcha_public_key  = '6LdhRssSAAAAAFfLt1Wkw43hoaA8RTIgso9-tvtc'
    config.recaptcha_private_key = '6LdhRssSAAAAAGwzl069pJQBdmzCZigm1nV-dmqK'

    config.opencorporates_key = ENV["OPENCORPORATES_KEY"]
    # config.recaptcha_proxy = ...
    #
    # IMPORTANT: please be sure to register for your own recaptcha keys before deploying a live site
    # It's quick and easy.  Just follow instructions at https://www.google.com/recaptcha/admin/create
    #
    # The below keys are fine for testing but should not be used in production sites.

    # config.read_only = true
    # defaults to false
    # disallows creating, updating, and deleting cards.

    # config.cache_store = :file_store, 'tmp/cache'
    # determines caching mechanism.  options include: file_store, memory_store, mem_cache_store, dalli_store...
    #
    # for production, we highly recommend memcache
    # here's a sample configuration for use with the dalli gem
    # config.cache_store = :dalli_store, []

    # config.paths['files'] = 'files'
    # where uploaded files are actually stored. (eg Image and File cards)

    # config.paths['local-mods'] = 'mods'
    # where mods are stored

    # config.allow_inline_styles = false
    # don't strip style attributes (not recommended)

    # config.override_host = nil
    # don't autodetect host (example.com) from web requests

    # config.override_protocol = nil
    # don't autodetect protocol (http/https) from web requests

    config.autoload_paths += Dir["#{root}/test/*.rb"]
    config.autoload_paths += Dir["#{root}/test/**/"]
    config.file_buckets = {
      s3_live_bucket: {
        read_only: true,
        provider: "fog/aws",
        directory: "wikirate",
        subdirectory: "files",
        credentials: {
          provider: 'AWS',
          aws_access_key_id: ENV["LIVE_BUCKET_AWS_ACCESS_KEY_ID"],
          aws_secret_access_key: ENV["LIVE_BUCKET_AWS_SECRET_ACCESS_KEY"],
          region: 'eu-central-1'
        },
        # credentials: YAML.load_file("/home/runner/wikirate/config/live_bucket_read_credentials.yml"),
        attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
        public: true
      },
      s3_staging_bucket: {
        provider: "fog/aws",
        directory: "wikirate-staging",
        credentials: {
          provider: 'AWS', # required
          aws_access_key_id: ENV["STAGING_BUCKET_AWS_ACCESS_KEY_ID"],
          aws_secret_access_key: ENV["STAGING_BUCKET_AWS_SECRET_ACCESS_KEY"],
          region: 'eu-central-1', # optional, defaults to 'us-east-1'
        },
        # credentials: YAML.load_file("/home/runner/wikirate/config/staging_bucket_credentials.yml"),
        attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
        subdirectory: "files",
        public: true
      }
    }

  end
end
