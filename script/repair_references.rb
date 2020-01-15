#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin Card::WagnBotID

Card::Reference.repair_all
