class MetricAnswerLookupTable < ActiveRecord::Migration
  def up
    create_table :metric_answers do |t|
      t.integer  :metric_answer_id
      t.integer  :metric_id
      t.integer  :designer_id
      t.integer  :company_id
      t.integer  :policy_id
      t.integer  :metric_type_id
      t.integer  :year
      t.string   :metric_name
      t.string   :company_name
      t.string   :value
      t.datetime :updated_at
      t.boolean  :imported
    end

    add_index :metric_answers, :metric_answer_id,
              name: "metric_answer_id_index",
              unique: true
    add_index :metric_answers, :metric_id, name: "metric_id_index"
    add_index :metric_answers, :designer_id, name: "designer_id_index"
    add_index :metric_answers, :company_id, name: "company_id_index"
    add_index :metric_answers, :policy_id, name: "policy_id_index"
    add_index :metric_answers, :metric_type_id, name: "metric_type_id_index"
    add_index :metric_answers, :value, name: "value_index"
  end

  def down
    drop_table :metric_answers
  end
end
