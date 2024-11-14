# -*- encoding : utf-8 -*-

class RenameRecordId < Cardio::Migration::Schema
  def up
    rename_column :answers, :record_id, :record_log_id
    rename_index :answers, "record_id_index", "record_log_id_index"
    rename_column :relationships, :record_id, :record_log_id
    rename_index :relationships, "record_id_index", "record_log_id_index"
  end
end
