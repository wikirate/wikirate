#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
require "decko/swagger"
Card::Auth.signin Card::WagnBotID

yaml_dir = File.dirname(__FILE__) + "/swagger"
swag = Decko::Swagger.new yaml_dir
hash = swag.merge_swag "input"
swag.output_to_file hash
