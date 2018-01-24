class AnswerLookupTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :answers if table_exists? :answers
    create_table :answers do |t|
      t.integer :answer_id
      t.integer :metric_id
      t.integer :designer_id
      t.integer :company_id
      t.integer :record_id
      t.integer :policy_id
      t.integer :metric_type_id
      t.integer :year
      t.string :metric_name
      t.string :company_name
      t.string :designer_name
      t.string :title_name
      t.string :record_name
      t.string :value
      t.decimal :numeric_value, precision: 30, scale: 5
      t.datetime :updated_at
      t.boolean :imported
      t.boolean :latest
    end

    add_index :answers, :answer_id, name: "answer_id_index", unique: true
    add_index :answers, :metric_id, name: "metric_id_index"
    add_index :answers, :record_id, name: "record_id_index"
    add_index :answers, :designer_id, name: "designer_id_index"
    add_index :answers, :company_id, name: "company_id_index"
    add_index :answers, :policy_id, name: "policy_id_index"
    add_index :answers, :metric_type_id, name: "metric_type_id_index"
    add_index :answers, :value, name: "value_index"
  end

  def down
    drop_table :answers
  end
end
