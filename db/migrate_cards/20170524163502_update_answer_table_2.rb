# -*- encoding : utf-8 -*-

class UpdateAnswerTable2 < Card::Migration
  def up
    Answer.refresh_all :editor_id
  end
end
