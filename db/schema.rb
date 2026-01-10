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

ActiveRecord::Schema[8.1].define(version: 2026_01_05_193332) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "back", null: false
    t.string "category", null: false
    t.integer "correct_count", default: 0, null: false
    t.integer "correct_streak", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "deck_id", null: false
    t.string "front", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.jsonb "wrong_answers", default: [], null: false
    t.index ["deck_id", "front"], name: "index_cards_on_deck_id_and_front", unique: true
  end

  create_table "decks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_decks_on_user_id_and_name", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "polar_subscription_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["polar_subscription_id"], name: "index_subscriptions_on_polar_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "cards", "decks"
  add_foreign_key "decks", "users"
  add_foreign_key "subscriptions", "users"
end
