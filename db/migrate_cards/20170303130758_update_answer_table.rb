# -*- encoding : utf-8 -*-

class UpdateAnswerTable < Card::Migration
  def up
    Answer.refresh nil, :creator_id
  end
end
