require File.expand_path("../boot", __FILE__)

require "decko/all"

module Wikirate
  # WikiRate application object. holds config options
  class Application < Decko::Application
    # Decko inherits Rails configuration options.
    # See http://guides.rubyonrails.org/configuring.html

    # config.recaptcha_public_key  = ''
    # config.recaptcha_private_key = ''
    # config.recaptcha_proxy = ...
    #
    # IMPORTANT: please be sure to register for your own recaptcha keys
    # before deploying a live site. It's quick and easy.
    # Just follow instructions at https://www.google.com/recaptcha/admin/create
    #
    # The below keys are fine for testing but should not be used in production sites.

    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }
    config.action_mailer.perform_deliveries = true

    # config.view_cache = false

    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { address: "localhost", port: 1025,
    #                                        openssl_verify_mode: 'none' }
    # config.action_mailer.smtp_settings = {}

    # config.read_only = true
    # defaults to false
    # disallows creating, updating, and deleting cards.

    # config.cache_store = :file_store, 'tmp/cache'
    # determines caching mechanism.
    # options include: file_store, memory_store, mem_cache_store, dalli_store...
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
    # config.request_logger = false
    # config.paths['request_log'] = 'shared/log'

    config.autoload_paths += Dir["#{root}/test/*.rb"]
    config.autoload_paths += Dir["#{root}/test/**/"]

    # config.file_buckets = {
    #      s3_live_bucket: {
    #          proveedor: "niebla / aws",
    #          directorio: "wikirate",
    #          subdirectorio: "archivos",
    #          atributos: {"Cache-Control" => "max-age = # {365.day.to_i}"},
    #          público: cierto,
    #          credenciales: {
    #            proveedor: 'AWS', se requiere #
    #            aws_access_key_id: 'XXXXXXX', # requerido
    #            aws_secret_access_key: 'XXXXXX', # requerido
    #            region: 'eu-central-1', # opcional, por defecto es 'us-east-1'
    #          },
    #          read_only: cierto,
    #          # si public está configurado como falso, se necesita la siguiente opción:
    #          authenticated_url_expiration: 180
    #      },
    #      s3_staging_bucket: {
    #          proveedor: "niebla / aws",
    #          directorio: "wikirate",
    #          subdirectorio: "archivos",
    #          atributos: {"Cache-Control" => "max-age = # {365.day.to_i}"},
    #          público: cierto,
    #          credenciales: {
    #            proveedor: 'AWS', se requiere #
    #            aws_access_key_id: 'XXXXXXX', # requerido
    #            aws_secret_access_key: 'XXXXXX', # requerido
    #            region: 'eu-central-1', # opcional, por defecto es 'us-east-1'
    #          },
    #          read_only: cierto,
    #          # si public está configurado como falso, se necesita la siguiente opción:
    #          authenticated_url_expiration: 180
    #      }
    # }
  end
end
