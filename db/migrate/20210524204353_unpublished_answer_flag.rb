class UnpublishedAnswerFlag < Cardio::Migration::DeckStructure
  def change
    add_column :answers, :unpublished, :boolean
  end
end
