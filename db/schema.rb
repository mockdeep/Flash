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

ActiveRecord::Schema[8.1].define(version: 2026_08_07_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "card_distractors", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.datetime "created_at", null: false
    t.string "text", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "text"], name: "index_card_distractors_on_card_id_and_text", unique: true
  end

  create_table "card_suggestions", force: :cascade do |t|
    t.string "back", null: false
    t.bigint "card_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "front", null: false
    t.string "state", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["card_id", "state"], name: "index_card_suggestions_on_card_id_and_state"
    t.index ["card_id"], name: "index_card_suggestions_on_card_id"
    t.index ["user_id"], name: "index_card_suggestions_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "back"
    t.string "category"
    t.integer "correct_count", default: 0, null: false
    t.integer "correct_streak", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "deck_id", null: false
    t.string "example_back"
    t.string "example_front"
    t.string "front"
    t.bigint "item_id", null: false
    t.string "reading"
    t.bigint "source_card_id"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["item_id"], name: "index_cards_on_item_id"
    t.index ["source_card_id"], name: "index_cards_on_source_card_id"
    t.index ["type"], name: "index_cards_on_type"
  end

  create_table "data_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "language"
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_data_sets_on_user_id_and_name", unique: true
  end

  create_table "decks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "data_set_id", null: false
    t.string "distractor_pool", null: false
    t.datetime "last_studied_at"
    t.integer "level", null: false
    t.boolean "ordered", default: false, null: false
    t.string "share_token"
    t.integer "study_goal", null: false
    t.bigint "topic_id"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private", null: false
    t.index ["data_set_id"], name: "index_decks_on_data_set_id"
    t.index ["share_token"], name: "index_decks_on_share_token", unique: true
    t.index ["topic_id"], name: "index_decks_on_topic_id"
    t.index ["type"], name: "index_decks_on_type"
    t.index ["visibility"], name: "index_decks_on_visibility"
  end

  create_table "item_distractors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "distractor_item_id", null: false
    t.bigint "item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["distractor_item_id"], name: "index_item_distractors_on_distractor_item_id"
    t.index ["item_id", "distractor_item_id"], name: "index_item_distractors_on_item_id_and_distractor_item_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.bigint "data_set_id", null: false
    t.string "example"
    t.string "paired_example"
    t.string "reading"
    t.string "side", null: false
    t.string "text", null: false
    t.datetime "updated_at", null: false
    t.index ["data_set_id", "side", "text"], name: "index_items_on_data_set_id_and_side_and_text", unique: true
  end

  create_table "pairings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "item_id", null: false
    t.bigint "paired_item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "paired_item_id"], name: "index_pairings_on_item_id_and_paired_item_id", unique: true
    t.index ["paired_item_id"], name: "index_pairings_on_paired_item_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creem_subscription_id"
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.string "plan_name"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["creem_subscription_id"], name: "index_subscriptions_on_creem_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_topics_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_topics_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.integer "study_goal", null: false
    t.string "time_zone", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "card_distractors", "cards", on_delete: :cascade
  add_foreign_key "card_suggestions", "cards", on_delete: :cascade
  add_foreign_key "card_suggestions", "users", on_delete: :cascade
  add_foreign_key "cards", "cards", column: "source_card_id", on_delete: :nullify
  add_foreign_key "cards", "decks"
  add_foreign_key "cards", "items", on_delete: :cascade
  add_foreign_key "data_sets", "users", on_delete: :cascade
  add_foreign_key "decks", "data_sets", on_delete: :cascade
  add_foreign_key "decks", "topics", on_delete: :nullify
  add_foreign_key "item_distractors", "items", column: "distractor_item_id", on_delete: :cascade
  add_foreign_key "item_distractors", "items", on_delete: :cascade
  add_foreign_key "items", "data_sets", on_delete: :cascade
  add_foreign_key "pairings", "items", column: "paired_item_id", on_delete: :cascade
  add_foreign_key "pairings", "items", on_delete: :cascade
  add_foreign_key "subscriptions", "users"
  add_foreign_key "topics", "users", on_delete: :cascade
end
