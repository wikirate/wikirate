class UnpublishedAnswerFlag < Cardio::Migration::Schema
  def change
    add_column :answers, :unpublished, :boolean
  end
end
