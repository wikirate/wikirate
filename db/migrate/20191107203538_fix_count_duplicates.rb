class FixCountDuplicates < ActiveRecord::Migration[6.0]
  def change
    delete_duplicates
    remove_index :counts, name: "left_id_index"
    remove_index :counts, name: "right_id_index"
    add_index :counts, [:left_id, :right_id], name: "left_id_right_id_index"
  end

  def delete_duplicates
    dup_ids = duplicate_ids
    return unless dup_ids.present?

    Card.connection.execute(
      "delete from counts where id in (#{dup_ids.join ', '})"
    )
  end

  def duplicate_ids
    Card.connection.exec_query(
      "select c1.id from counts c1 " \
      "join counts c2 on c1.left_id = c2.left_id and c1.right_id = c2.right_id " \
      "where c1.id < c2.id"
    ).rows
  end
end
