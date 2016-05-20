# -*- encoding : utf-8 -*-

class ScriptWikirateCommon < Card::Migration
  def up
    create_or_update name: 'script wikirate common',
                     type_id: 5466,
                     codename: 'script_wikirate_common'
  end
end
