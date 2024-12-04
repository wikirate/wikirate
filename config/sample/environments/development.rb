# -*- encoding : utf-8 -*-

Decko::Deck.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb

  if ENV["WIKIRATE_IDE"] == "RubyMine"
    BetterErrors.editor = "x-mine://open?file=%<file>s&line=%<line>s"
  end
end
