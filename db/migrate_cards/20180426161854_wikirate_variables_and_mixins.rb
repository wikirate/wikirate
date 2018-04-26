# -*- encoding : utf-8 -*-

class WikirateVariablesAndMixins < Card::Migration
  def up
    if Card::Codename.exist? :wikirate_stylesheets
      update_card :wikirate_stylesheets, name: "coded stylesheets",
                  codename: "coded_stylesheets",
                  update_referers: true

    end
    item_name = Card.fetch_name(:style_mixins_and_variables)
    card = Card["wikirate skin", :stylesheets]
    card.insert_item! 0, item_name

    # for some reasons `update_referers` doesn't work
    if card.content.include "wikirate stylesheets"
      card.update_attributes!(
        content: card.content.sub("wikirate stylesheets", "coded stylesheets")
      )
    end
  end
end
