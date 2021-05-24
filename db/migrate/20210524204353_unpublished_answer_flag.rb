class UnpublishedAnswerFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :unpublished, :boolean
  end
end
