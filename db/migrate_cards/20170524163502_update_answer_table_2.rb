# -*- encoding : utf-8 -*-

class UpdateAnswerTable2 < Card::Migration
  def up
    Answer.refresh nil, :editor_id
  end
end
