#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.dirname(__FILE__) + "../../config/environment"

Decko.config.action_mailer.perform_deliveries = false

Card::Auth.as_bot

ARGV.each do |filename|
  raw_json = File.read "#{Dir.pwd}/#{filename}"
  json = JSON.parse raw_json
  Card.merge_list json["card"]["value"], output_file: "/tmp/unmerged_#{filename}"
end
