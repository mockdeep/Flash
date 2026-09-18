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

ActiveRecord::Schema[8.1].define(version: 2026_09_18_033700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "card_distractors", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.datetime "created_at", null: false
    t.string "text", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "text"], name: "index_card_distractors_on_card_id_and_text", unique: true
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
    t.string "reading"
    t.bigint "source_card_id"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["deck_id", "front"], name: "index_cards_on_deck_id_and_front", unique: true, where: "(front IS NOT NULL)"
    t.index ["source_card_id"], name: "index_cards_on_source_card_id"
    t.index ["type"], name: "index_cards_on_type"
  end

  create_table "decks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "distractor_pool", null: false
    t.datetime "last_studied_at"
    t.integer "level", null: false
    t.string "name"
    t.boolean "ordered", default: false, null: false
    t.string "share_token"
    t.integer "study_goal", null: false
    t.bigint "topic_id"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility", default: "private", null: false
    t.bigint "word_list_id"
    t.index ["share_token"], name: "index_decks_on_share_token", unique: true
    t.index ["topic_id"], name: "index_decks_on_topic_id"
    t.index ["type"], name: "index_decks_on_type"
    t.index ["user_id", "name"], name: "index_decks_on_user_id_and_name", unique: true, where: "(name IS NOT NULL)"
    t.index ["user_id"], name: "index_decks_on_user_id"
    t.index ["visibility"], name: "index_decks_on_visibility"
    t.index ["word_list_id"], name: "index_decks_on_word_list_id"
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "headword", null: false
    t.string "language", null: false
    t.string "reading"
    t.datetime "updated_at", null: false
    t.index ["language", "headword", "reading"], name: "index_entries_on_language_and_headword_and_reading", unique: true, nulls_not_distinct: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.integer "lock_type", limit: 2
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["created_at"], name: "index_good_jobs_on_created_at"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_on_discarded", order: :desc, where: "((finished_at IS NOT NULL) AND (error IS NOT NULL))"
    t.index ["id"], name: "index_good_jobs_on_unfinished_or_errored", where: "((finished_at IS NULL) OR (error IS NOT NULL))"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_for_candidate_dequeue_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_on_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at", "id"], name: "index_good_jobs_on_queue_name_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["queue_name"], name: "index_good_jobs_on_queue_name"
    t.index ["scheduled_at", "queue_name"], name: "index_good_jobs_on_scheduled_at_and_queue_name"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "sense_distractors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "distractor_sense_id", null: false
    t.datetime "last_missed_at", null: false
    t.integer "miss_count", null: false
    t.bigint "sense_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["distractor_sense_id"], name: "index_sense_distractors_on_distractor_sense_id"
    t.index ["user_id", "sense_id", "distractor_sense_id"], name: "index_sense_distractors_on_user_sense_and_distractor", unique: true
  end

  create_table "sense_examples", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "sense_id", null: false
    t.string "sentence", null: false
    t.string "translation"
    t.datetime "updated_at", null: false
    t.index ["sense_id", "sentence"], name: "index_sense_examples_on_sense_id_and_sentence", unique: true
  end

  create_table "sense_memberships", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "sense_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "word_list_id", null: false
    t.index ["sense_id", "word_list_id"], name: "index_sense_memberships_on_sense_id_and_word_list_id", unique: true
    t.index ["word_list_id"], name: "index_sense_memberships_on_word_list_id"
  end

  create_table "senses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "entry_id", null: false
    t.string "gloss", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id", "gloss"], name: "index_senses_on_entry_id_and_gloss", unique: true
  end

  create_table "skill_scores", force: :cascade do |t|
    t.integer "correct_count", default: 0, null: false
    t.integer "correct_streak", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "sense_id", null: false
    t.string "skill", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["sense_id"], name: "index_skill_scores_on_sense_id"
    t.index ["user_id", "sense_id", "skill"], name: "index_skill_scores_on_user_id_and_sense_id_and_skill", unique: true
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

  create_table "word_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "language"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_word_lists_on_user_id_and_name", unique: true
  end

  add_foreign_key "card_distractors", "cards", on_delete: :cascade
  add_foreign_key "cards", "cards", column: "source_card_id", on_delete: :nullify
  add_foreign_key "cards", "decks"
  add_foreign_key "decks", "topics", on_delete: :nullify
  add_foreign_key "decks", "users", on_delete: :cascade
  add_foreign_key "decks", "word_lists"
  add_foreign_key "sense_distractors", "senses", column: "distractor_sense_id", on_delete: :cascade
  add_foreign_key "sense_distractors", "senses", on_delete: :cascade
  add_foreign_key "sense_distractors", "users", on_delete: :cascade
  add_foreign_key "sense_examples", "senses", on_delete: :cascade
  add_foreign_key "sense_memberships", "senses", on_delete: :cascade
  add_foreign_key "sense_memberships", "word_lists", on_delete: :cascade
  add_foreign_key "senses", "entries"
  add_foreign_key "skill_scores", "senses", on_delete: :cascade
  add_foreign_key "skill_scores", "users", on_delete: :cascade
  add_foreign_key "subscriptions", "users"
  add_foreign_key "topics", "users", on_delete: :cascade
  add_foreign_key "word_lists", "users", on_delete: :cascade
end
