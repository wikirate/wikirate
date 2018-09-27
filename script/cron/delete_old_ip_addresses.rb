#!/usr/bin/env ruby

require File.expand_path("../../../config/environment", __FILE__)

Card::Act.where("acted_at < ?", 6.months.ago).update_all ip_address: nil
