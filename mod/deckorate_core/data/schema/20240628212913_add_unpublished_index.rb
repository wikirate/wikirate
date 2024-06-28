# -*- encoding : utf-8 -*-

class AddUnpublishedIndex < Cardio::Migration::Schema
  def up
    add_index :answers, :unpublished, name: "answers_unpublished_index"
  end

  def down
    remove_index :answers, name: "answers_unpublished_index"
  end
end
