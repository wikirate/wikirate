# -*- encoding : utf-8 -*-

class FixEditorRules < Card::Migration
  def up
    ensure_card [:all, :input], content: "[[prosemirror editor]]"
    ensure_card [:pointer, :type, :input], content: "[[list]]"
  end
end
