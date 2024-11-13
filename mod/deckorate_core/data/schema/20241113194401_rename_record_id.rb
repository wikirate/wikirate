# -*- encoding : utf-8 -*-

class RenameRecordId < Cardio::Migration::Schema
  def up
    rename_column :answers, :record_id, :record_log_id
  end
end
