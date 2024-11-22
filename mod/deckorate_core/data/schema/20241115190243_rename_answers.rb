# -*- encoding : utf-8 -*-

class RenameAnswers < Cardio::Migration::Schema
  def up
    rename_table :answers, :records
    rename_column :records, :answer_id, :record_id
    rename_index :records, "answer_id_index", "record_id_index"
    # rename_index :records,
    #              "index_answers_on_metric_id_and_company_id_and_year",
    #              "index_records_on_metric_id_and_company_id_and_year"
    # rename_index :records,
    #              "index_answers_on_metric_id_and_company_id",
    #              "index_records_on_metric_id_and_company_id"

    rename_column :relationships, :answer_id, :record_id
    rename_column :relationships, :inverse_answer_id, :inverse_record_id
    rename_index :relationships, "answer_id_index", "record_id_index"
  end
end
