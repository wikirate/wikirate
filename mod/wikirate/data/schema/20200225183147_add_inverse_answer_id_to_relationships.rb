class AddInverseAnswerIdToRelationships < Cardio::Migration::Schema
  def up
    add_column :relationships, :inverse_answer_id, :integer
  end
end
