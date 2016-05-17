#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.current_id = Card::WagnBotID

Card::Reference.repair_all
