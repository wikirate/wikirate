# -*- encoding : utf-8 -*-

class RemoveContentOfCodedCards < Card::Migration
  def up
    ensure_card "script: wikirate",
                codename: "script_wikirate",
                type_id: Card::CoffeeScriptID
    ensure_card "style: wikirate",
                codename: "style_wikirate",
                type_id: Card::ScssID

    ensure_card "script: homepage",
                codename: "script_homepage",
                type_id: Card::CoffeeScriptID

    ensure_card "script: source",
                codename: "script_source",
                type_id: Card::CoffeeScriptID

    update_card :style_homepage_layout, codename: "style_homepage",
                                        name: "style: homepage"

    Card[:coded_stylesheets].item_cards.each do |card|
      card.update_attributes! db_content: ""
    end
    remove_js_libraries

    delete_code_card :chosen_style

    Card::Self::ScriptMetrics::FILE_NAMES.each do |file|
      delete_code_card "script_#{file}"
    end
    Card::Self::ScriptWikirate::FILE_NAMES.each do |file|
      delete_code_card "script_#{file}"
    end
    Card::Self::StyleWikirate::FILE_NAMES.each do |file|
      delete_code_card "style_#{file}"
    end
  end

  def remove_js_libraries
    delete_card "chosen proto script"
    delete_card "chosen script"
    if (card = Card.fetch("script: libraries"))
      card.drop_item "chosen proto script"
      card.drop_item "chosen script"
      card.save!
    end
  end

end
