class AddInverseAnswerIdToRelationships < Cardio::Migration::DeckStructure
  def up
    add_column :relationships, :inverse_answer_id, :integer
  end
end
