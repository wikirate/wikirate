# -*- encoding : utf-8 -*-

class UpdateAnswerTable < Card::Migration
  disable_ddl_transaction!
  def up
    Answer.refresh_all :creator_id
  end
end
