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

ActiveRecord::Schema[8.1].define(version: 2026_09_26_154135) do
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
    t.string "goal_mode", default: "session", null: false
    t.datetime "last_studied_at"
    t.integer "level", null: false
    t.string "name"
    t.boolean "ordered", default: false, null: false
    t.string "share_token"
    t.integer "study_goal", null: false
    t.date "target_date"
    t.integer "target_level"
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

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "enqueued_at"
    t.datetime "failed_at"
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.text "metadata"
    t.text "on_failure"
    t.text "on_finish"
    t.text "on_success"
    t.integer "total_jobs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.bigint "batch_id"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "study_days", force: :cascade do |t|
    t.integer "completed_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "deck_id", null: false
    t.integer "goal"
    t.date "studied_on", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id", "studied_on"], name: "index_study_days_on_deck_id_and_studied_on", unique: true
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
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "study_days", "decks", on_delete: :cascade
  add_foreign_key "subscriptions", "users"
  add_foreign_key "topics", "users", on_delete: :cascade
  add_foreign_key "word_lists", "users", on_delete: :cascade
end
