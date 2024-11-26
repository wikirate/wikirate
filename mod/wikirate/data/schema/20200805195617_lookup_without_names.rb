class LookupWithoutNames < Cardio::Migration::Schema
  def change
    add_column :answers, :title_id, :integer

    remove_column :answers, :metric_name
    remove_column :answers, :designer_name
    remove_column :answers, :title_name
    remove_column :answers, :company_name
    remove_column :answers, :answer_name

    remove_column :relationships, :subject_company_name
    remove_column :relationships, :object_company_name

    remove_index :counts, name: "left_id_right_id_index"
    add_index :counts, %i[left_id right_id], unique: true
  end
end
