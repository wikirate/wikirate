class RelationshipAnswerLookupTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :relationships if table_exists? :relationships
    create_table :relationships do |t|
      t.integer :relationship_id
      t.integer :metric_id
      t.integer :record_id
      t.integer :answer_id
      t.integer :object_company_id
      t.integer :subject_company_id
      t.integer :year
      t.string :object_company_name
      t.string :subject_company_name
      t.string :value
      t.decimal :numeric_value, precision: 30, scale: 5
      t.datetime :updated_at
      t.boolean :imported
      t.boolean :latest
    end

    add_index :relationships, :answer_id, name: "answer_id_index"
    add_index :relationships, :relationship_id, name: "relationship_id_index", unique: true
    add_index :relationships, :metric_id, name: "metric_id_index"
    add_index :relationships, :record_id, name: "record_id_index"
    add_index :relationships, :object_company_id, name: "object_company_id_index"
    add_index :relationships, :subject_company_id, name: "subject_company_id_index"
    add_index :relationships, :value, name: "value_index"
  end

  def down
    drop_table :relationships
  end
end
