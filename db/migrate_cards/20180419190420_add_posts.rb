# -*- encoding : utf-8 -*-

class AddPosts < Card::Migration
  def up
    merge_cards %w[post body details post+*right+*structure]
  end
end
