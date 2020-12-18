# -*- encoding : utf-8 -*-

class NewSourceHandling < Cardio::Migration
  def up
    Card["Source+*type+*structure"]&.delete!
  end
end
