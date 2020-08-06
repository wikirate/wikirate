class LookupWithoutNames < ActiveRecord::Migration[6.0]
  def change
    add_column :answers, :title_id, :integer

    remove_column :answers, :metric_name
    remove_column :answers, :designer_name
    remove_column :answers, :title_name
    remove_column :answers, :company_name
    remove_column :answers, :record_name

    remove_column :relationships, :subject_company_name
    remove_column :relationships, :object_company_name
  end
end
