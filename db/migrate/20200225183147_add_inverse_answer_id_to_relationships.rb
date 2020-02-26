class AddInverseAnswerIdToRelationships < ActiveRecord::Migration[6.0]
  def up
    add_column :relationships, :inverse_answer_id, :integer
  end
end
