# -*- encoding : utf-8 -*-

require "../../vendor/card-mods/card_mod_gem"

CardModGem.mod "deckorate_search" do |s, d|
  s.version = "0.1"
  s.summary = ""
  s.description = ""
  s.metadata["card-mod-group"] = "deckorate"
  d.depends_on "opensearch-ruby"
end
