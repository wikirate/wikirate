# -*- encoding : utf-8 -*-

class MoveStructureToCode < Card::Migration
  def up
    delete "topic+*type+*structure"
    delete "company+*type+*structure"
  end
end
