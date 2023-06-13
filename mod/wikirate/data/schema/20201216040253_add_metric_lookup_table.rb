class AddMetricLookupTable < Cardio::Migration::Schema
  def change
    drop_table :metrics if table_exists? :metrics
    create_table :metrics do |t|
      t.integer :metric_id
      t.integer :designer_id
      t.integer :title_id
      t.integer :scorer_id
      t.integer :metric_type_id
      t.integer :value_type_id
      t.integer :policy_id
      t.string :unit
      t.boolean :hybrid
    end

    add_index :metrics, :metric_id, name: "metrics_metric_id_index", unique: true
    add_index :metrics, :designer_id, name: "metrics_designer_id_index"
    add_index :metrics, :title_id, name: "metrics_title_id_index"
    add_index :metrics, :scorer_id, name: "metrics_scorer_id_index"
    add_index :metrics, :metric_type_id, name: "metrics_metric_type_id_index"
    add_index :metrics, :value_type_id, name: "metrics_value_type_id_index"
    add_index :metrics, :policy_id, name: "metrics_policy_id_index"

    remove_columns :answers, :designer_id, :title_id, :metric_type_id, :policy_id
  end
end
