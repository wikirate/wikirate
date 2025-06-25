#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin Card::DeckoBotID

Card::Reference.repair_all
