# -*- encoding : utf-8 -*-

class UpdateWikirateScriptItems < Card::Migration
  def up
    script_card = Card.fetch("script: wikirate scripts")
    script_card.drop_item! "note chosen" # wikirate common
    ensure_card 'script: new source page',
                type_id: Card::CoffeeScriptID,
                codename: 'script_new_source_page'
    ensure_card 'script: new note page',
                type_id: Card::CoffeeScriptID,
                codename: 'script_new_note_page'
    create_or_update name: 'script: homepage carousel init',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_homepage_carousel_init'
    create_or_update name: 'homepage ie8 handling script',
                     type_id: Card::JavaScriptID,
                     codename: 'homepage_ie8_handling_script'
    create_or_update name: 'script: company page',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_company_page'
    create_or_update name: 'script: showcase',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_showcase'
    create_or_update name: 'script: overview page',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_overview_page'
    if (card = Card["import page script"])
      card.update_attributes! name: 'script: import page',
                              type_id: Card::CoffeeScriptID,
                              codename: 'script_import_page',
                              update_referers: true
    end
  end
end
