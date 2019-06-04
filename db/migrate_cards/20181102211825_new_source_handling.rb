# -*- encoding : utf-8 -*-

class NewSourceHandling < Card::Migration
  def up
    Card["Source+*type+*structure"]&.delete!
  end
end
