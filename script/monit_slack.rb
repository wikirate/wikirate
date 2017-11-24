#!/usr/bin/ruby

require 'net/https'
require 'json'

slack_config_path File.expand_path("../../config/slack.yml", __FILE__)
raise "no slack config" unless File.exists? slack_config_path
slack_config = YAML.load slack_config_path

uri = URI.parse("https://hooks.slack.com/services/#{slack_config[:service_hook]}")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
request.body = {
    "channel"  => "#product",
    "username" => "mmonit",
    "text"     => "[#{ENV['MONIT_HOST']}] #{ENV['MONIT_SERVICE']} - #{ENV['MONIT_DESCRIPTION']}"
}.to_json
response = http.request(request)
puts response.body
