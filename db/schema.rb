# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_11_10_200407) do
  create_table "answers", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "answer_id"
    t.integer "metric_id", null: false
    t.integer "company_id", null: false
    t.integer "record_id"
    t.integer "year", null: false
    t.string "value", limit: 1024
    t.decimal "numeric_value", precision: 30, scale: 5
    t.datetime "updated_at", precision: nil
    t.boolean "imported"
    t.boolean "latest"
    t.string "checkers"
    t.integer "creator_id", null: false
    t.integer "editor_id"
    t.datetime "created_at", precision: nil
    t.string "overridden_value"
    t.boolean "calculating"
    t.integer "source_count"
    t.string "source_url", limit: 1024
    t.string "comments", limit: 1024
    t.integer "verification"
    t.boolean "unpublished"
    t.integer "open_flags"
    t.integer "route", limit: 1
    t.index ["answer_id"], name: "answer_id_index", unique: true
    t.index ["company_id"], name: "company_id_index"
    t.index ["metric_id", "company_id", "year"], name: "index_answers_on_metric_id_and_company_id_and_year", unique: true
    t.index ["metric_id", "company_id"], name: "index_answers_on_metric_id_and_company_id"
    t.index ["metric_id"], name: "metric_id_index"
    t.index ["numeric_value"], name: "numeric_value_index"
    t.index ["record_id"], name: "record_id_index"
    t.index ["value"], name: "value_index", length: 100
  end

  create_table "card_actions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_id"
    t.integer "card_act_id"
    t.integer "super_action_id"
    t.integer "action_type"
    t.boolean "draft"
    t.text "comment"
    t.index ["card_act_id"], name: "card_actions_card_act_id_index"
    t.index ["card_id"], name: "card_actions_card_id_index"
  end

  create_table "card_acts", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_id"
    t.integer "actor_id"
    t.datetime "acted_at", precision: nil
    t.string "ip_address"
    t.index ["acted_at"], name: "acts_acted_at_index"
    t.index ["actor_id"], name: "card_acts_actor_id_index"
    t.index ["card_id"], name: "card_acts_card_id_index"
  end

  create_table "card_changes", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_action_id"
    t.integer "field"
    t.text "value", size: :medium
    t.index ["card_action_id"], name: "card_changes_card_action_id_index"
  end

  create_table "card_counts", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "left_id"
    t.integer "right_id"
    t.integer "value"
    t.boolean "flag", default: false
    t.index ["left_id", "right_id"], name: "index_card_counts_on_left_id_and_right_id", unique: true
  end

  create_table "card_references", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "referer_id", default: 0, null: false
    t.string "referee_key", default: ""
    t.integer "referee_id"
    t.string "ref_type", limit: 1, default: "", null: false
    t.integer "is_present"
    t.index ["ref_type"], name: "card_references_ref_type_index"
    t.index ["referee_id"], name: "card_references_referee_id_index"
    t.index ["referee_key"], name: "card_references_referee_key_index"
    t.index ["referer_id"], name: "card_references_referer_id_index"
  end

  create_table "card_virtuals", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "left_id"
    t.integer "right_id"
    t.string "left_key"
    t.text "content", size: :medium
    t.datetime "updated_at", precision: nil
    t.index ["left_id"], name: "right_id_index"
    t.index ["right_id"], name: "left_id_index"
  end

  create_table "cards", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "codename"
    t.integer "left_id"
    t.integer "right_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "creator_id", null: false
    t.integer "updater_id", null: false
    t.string "read_rule_class"
    t.integer "read_rule_id"
    t.boolean "trash", null: false
    t.integer "type_id", null: false
    t.text "db_content", size: :medium
    t.text "search_content", size: :medium
    t.index ["codename"], name: "cards_codename_index", unique: true
    t.index ["created_at"], name: "cards_created_at_index"
    t.index ["key"], name: "cards_key_index", unique: true
    t.index ["left_id"], name: "cards_left_id_index"
    t.index ["name", "search_content"], name: "name, search_content_index", type: :fulltext
    t.index ["name"], name: "cards_name_index"
    t.index ["read_rule_id"], name: "cards_read_rule_id_index"
    t.index ["right_id"], name: "cards_right_id_index"
    t.index ["type_id"], name: "cards_type_id_index"
    t.index ["updated_at"], name: "cards_updated_at_index"
  end

  create_table "delayed_jobs", charset: "utf8mb3", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :medium, null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "metrics", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "metric_id"
    t.integer "designer_id"
    t.integer "title_id"
    t.integer "scorer_id"
    t.integer "metric_type_id"
    t.integer "value_type_id"
    t.integer "policy_id"
    t.string "unit"
    t.boolean "hybrid"
    t.boolean "unpublished"
    t.boolean "benchmark"
    t.index ["designer_id"], name: "metrics_designer_id_index"
    t.index ["metric_id"], name: "metrics_metric_id_index", unique: true
    t.index ["metric_type_id"], name: "metrics_metric_type_id_index"
    t.index ["policy_id"], name: "metrics_policy_id_index"
    t.index ["scorer_id"], name: "metrics_scorer_id_index"
    t.index ["title_id"], name: "metrics_title_id_index"
    t.index ["value_type_id"], name: "metrics_value_type_id_index"
  end

  create_table "relationships", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "relationship_id"
    t.integer "metric_id", null: false
    t.integer "record_id"
    t.integer "answer_id", null: false
    t.integer "object_company_id", null: false
    t.integer "subject_company_id", null: false
    t.integer "year", null: false
    t.string "value"
    t.decimal "numeric_value", precision: 30, scale: 5
    t.datetime "updated_at", precision: nil
    t.boolean "imported"
    t.boolean "latest"
    t.integer "inverse_metric_id", null: false
    t.integer "inverse_answer_id", null: false
    t.integer "route", limit: 1
    t.integer "editor_id"
    t.datetime "created_at", precision: nil
    t.integer "creator_id"
    t.index ["answer_id"], name: "answer_id_index"
    t.index ["metric_id", "subject_company_id", "object_company_id", "year"], name: "relationship_component_cards_index", unique: true
    t.index ["metric_id"], name: "metric_id_index"
    t.index ["object_company_id"], name: "object_company_id_index"
    t.index ["record_id"], name: "record_id_index"
    t.index ["relationship_id"], name: "relationship_id_index", unique: true
    t.index ["subject_company_id"], name: "subject_company_id_index"
    t.index ["value"], name: "value_index"
  end

  create_table "transform_migrations", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_schema_migrations_cards", unique: true
  end
end
