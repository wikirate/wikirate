# -*- encoding : utf-8 -*-

class UpdateAnswerTable < Card::Migration
  disable_ddl_transaction!
  def up
    Answer.refresh nil, :creator_id
  end
end
