class UnpublishedAnswerFlag < Cardio::Migration
  def change
    add_column :answers, :unpublished, :boolean
  end
end
