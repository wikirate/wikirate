# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_05_200729) do

  create_table "answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "answer_id"
    t.integer "metric_id", null: false
    t.integer "designer_id", null: false
    t.integer "company_id", null: false
    t.integer "record_id"
    t.integer "policy_id"
    t.integer "metric_type_id", null: false
    t.integer "year", null: false
    t.string "value", limit: 1024
    t.decimal "numeric_value", precision: 30, scale: 5
    t.datetime "updated_at"
    t.boolean "imported"
    t.boolean "latest"
    t.string "checkers"
    t.string "check_requester"
    t.integer "creator_id", null: false
    t.integer "editor_id"
    t.datetime "created_at"
    t.string "overridden_value"
    t.boolean "calculating"
    t.integer "source_count"
    t.string "source_url", limit: 1024
    t.string "comments", limit: 1024
    t.integer "title_id"
    t.index ["answer_id"], name: "answer_id_index", unique: true
    t.index ["company_id"], name: "company_id_index"
    t.index ["designer_id"], name: "designer_id_index"
    t.index ["metric_id", "company_id", "year"], name: "index_answers_on_metric_id_and_company_id_and_year", unique: true
    t.index ["metric_id"], name: "metric_id_index"
    t.index ["metric_type_id"], name: "metric_type_id_index"
    t.index ["numeric_value"], name: "numeric_value_index"
    t.index ["policy_id"], name: "policy_id_index"
    t.index ["record_id"], name: "record_id_index"
    t.index ["value"], name: "value_index", length: 100
  end

  create_table "card_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_id"
    t.integer "card_act_id"
    t.integer "super_action_id"
    t.integer "action_type"
    t.boolean "draft"
    t.text "comment"
    t.index ["card_act_id"], name: "card_actions_card_act_id_index"
    t.index ["card_id"], name: "card_actions_card_id_index"
  end

  create_table "card_acts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_id"
    t.integer "actor_id"
    t.datetime "acted_at"
    t.string "ip_address"
    t.index ["acted_at"], name: "acts_acted_at_index"
    t.index ["actor_id"], name: "card_acts_actor_id_index"
    t.index ["card_id"], name: "card_acts_card_id_index"
  end

  create_table "card_changes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_action_id"
    t.integer "field"
    t.text "value", size: :medium
    t.index ["card_action_id"], name: "card_changes_card_action_id_index"
  end

  create_table "card_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "referer_id", default: 0, null: false
    t.string "referee_key", default: "", null: false
    t.integer "referee_id"
    t.string "ref_type", limit: 1, default: "", null: false
    t.integer "is_present"
    t.index ["ref_type"], name: "card_references_ref_type_index"
    t.index ["referee_id"], name: "card_references_referee_id_index"
    t.index ["referee_key"], name: "card_references_referee_key_index"
    t.index ["referer_id"], name: "card_references_referer_id_index"
  end

  create_table "card_virtuals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "left_id"
    t.integer "right_id"
    t.text "content", size: :medium
    t.string "left_key"
    t.index ["left_id", "right_id"], name: "index_card_virtuals_on_left_id_and_right_id", unique: true
    t.index ["left_id"], name: "right_id_index"
    t.index ["right_id"], name: "left_id_index"
  end

  create_table "cards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "codename"
    t.integer "left_id"
    t.integer "right_id"
    t.integer "current_revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id", null: false
    t.integer "updater_id", null: false
    t.string "read_rule_class"
    t.integer "read_rule_id"
    t.integer "references_expired"
    t.boolean "trash", null: false
    t.integer "type_id", null: false
    t.text "db_content", size: :medium
    t.text "search_content", size: :medium
    t.index ["codename"], name: "cards_codename_index"
    t.index ["created_at"], name: "cards_created_at_index"
    t.index ["key"], name: "cards_key_index", unique: true
    t.index ["left_id", "right_id"], name: "index_cards_on_left_id_and_right_id", unique: true
    t.index ["left_id"], name: "cards_left_id_index"
    t.index ["name", "search_content"], name: "name, search_content_index", type: :fulltext
    t.index ["name"], name: "cards_name_index"
    t.index ["read_rule_id"], name: "cards_read_rule_id_index"
    t.index ["right_id"], name: "cards_right_id_index"
    t.index ["type_id"], name: "cards_type_id_index"
    t.index ["updated_at"], name: "cards_updated_at_index"
  end

  create_table "counts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "left_id"
    t.integer "right_id"
    t.integer "value"
    t.index ["left_id", "right_id"], name: "left_id_right_id_index"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :medium, null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "relationships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "relationship_id"
    t.integer "metric_id", null: false
    t.integer "record_id"
    t.integer "answer_id", null: false
    t.integer "object_company_id", null: false
    t.integer "subject_company_id", null: false
    t.integer "year", null: false
    t.string "value"
    t.decimal "numeric_value", precision: 30, scale: 5
    t.datetime "updated_at"
    t.boolean "imported"
    t.boolean "latest"
    t.integer "inverse_metric_id", null: false
    t.integer "inverse_answer_id", null: false
    t.index ["answer_id"], name: "answer_id_index"
    t.index ["metric_id", "object_company_id", "subject_company_id", "year"], name: "relationship_component_cards_index", unique: true
    t.index ["metric_id"], name: "metric_id_index"
    t.index ["object_company_id"], name: "object_company_id_index"
    t.index ["record_id"], name: "record_id_index"
    t.index ["relationship_id"], name: "relationship_id_index", unique: true
    t.index ["subject_company_id"], name: "subject_company_id_index"
    t.index ["value"], name: "value_index"
  end

  create_table "schema_migrations_cards", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_schema_migrations_cards", unique: true
  end

  create_table "schema_migrations_core_cards", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_schema_migrations_core_cards", unique: true
  end

  create_table "schema_migrations_deck", primary_key: "version", id: :string, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
  end

  create_table "schema_migrations_deck_cards", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_schema_migrations_deck_cards", unique: true
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id"
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "sessions_session_id_index"
  end

end
