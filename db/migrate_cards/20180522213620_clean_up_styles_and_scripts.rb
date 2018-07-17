# -*- encoding : utf-8 -*-

class CleanUpStylesAndScripts < Card::Migration
  def up
    delete_card "slick js"
    delete_card "script: fake loader"
    delete_card "script: old libraries"
    Card[:all, :script].drop_item! "script: old libraries"

    return unless (card = Card[:wikirate_skin, :stylesheets])
    card.update_attributes! content: "[[emergency style hacks]]"
  end
end
