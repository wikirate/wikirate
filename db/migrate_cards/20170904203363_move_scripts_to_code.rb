# -*- encoding : utf-8 -*-

class MoveScriptsToCode < Card::Migration
  def up
    Card["script: libraries"].drop_item! "general_popup_script"
    add_script "general_popup",
                type_id: Card::CoffeeScriptID,
                to: "script: wikirate scripts"

    %w[activate_readmore suggested_source empty_tab_content note_citation
       wikirate_coffee].each do |name|
      update_wikirate_script name
    end
    Card["script: wikirate scripts"].drop_item! "homepage ie8 handling script"
    Card["script: wikirate scripts"].drop_item! "wikirate coffee"
    Card["script: wikirate scripts"].drop_item! "modal window script"
  end

  def update_wikirate_script name
    Card["script: wikirate scripts"].drop_item! "#{name}_script"
    add_script name,
               type_id: Card::CoffeeScriptID,
               to: "script: wikirate scripts"
  end
end
