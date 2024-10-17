# -*- encoding : utf-8 -*-

class WikirateVariablesAndMixins < Cardio::Migration::Transform
  def up
    if Card::Codename.exist? :wikirate_stylesheets
      update_card :wikirate_stylesheets,
                  name: "coded stylesheets",
                  codename: "coded_stylesheets"
    else
      ensure_card "coded stylesheets", codename: "coded_stylesheets",
                                       type_id: Card::SkinIDå
    end
    item_name = :style_mixins_and_variables.cardname
    card = Card["wikirate skin", :stylesheets]
    card.insert_item! 0, item_name

    if card.content.include? "wikirate stylesheets"
      card.update!(
        content: card.content.sub("wikirate stylesheets", "coded stylesheets")
      )
    end
  end
end
