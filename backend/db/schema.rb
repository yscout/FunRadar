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

ActiveRecord::Schema[8.1].define(version: 2025_11_11_204851) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "activity_suggestions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.jsonb "payload", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_activity_suggestions_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "ai_generated_at"
    t.jsonb "ai_summary", default: {}, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.jsonb "final_match", default: {}, null: false
    t.text "notes"
    t.bigint "organizer_id", null: false
    t.uuid "share_token", default: -> { "gen_random_uuid()" }, null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.index ["share_token"], name: "index_events_on_share_token", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.uuid "access_token", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "invitee_email"
    t.bigint "invitee_id"
    t.string "invitee_name", null: false
    t.datetime "responded_at"
    t.integer "role", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_invitations_on_access_token", unique: true
    t.index ["event_id", "invitee_id"], name: "index_invitations_on_event_and_invitee", unique: true, where: "(invitee_id IS NOT NULL)"
    t.index ["event_id"], name: "index_invitations_on_event_id"
    t.index ["invitee_id"], name: "index_invitations_on_invitee_id"
  end

  create_table "match_votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "invitation_id", null: false
    t.string "match_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "match_id"], name: "index_match_votes_on_event_id_and_match_id"
    t.index ["event_id"], name: "index_match_votes_on_event_id"
    t.index ["invitation_id", "match_id"], name: "index_match_votes_on_invitation_id_and_match_id", unique: true
    t.index ["invitation_id"], name: "index_match_votes_on_invitation_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.jsonb "activities", default: [], null: false
    t.jsonb "available_times", default: [], null: false
    t.integer "budget_max"
    t.integer "budget_min"
    t.datetime "created_at", null: false
    t.text "ideas"
    t.bigint "invitation_id", null: false
    t.decimal "location_latitude", precision: 10, scale: 6
    t.decimal "location_longitude", precision: 10, scale: 6
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["invitation_id"], name: "index_preferences_on_invitation_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_signed_in_at"
    t.decimal "location_latitude", precision: 10, scale: 6
    t.decimal "location_longitude", precision: 10, scale: 6
    t.boolean "location_permission", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_users_on_lower_name", unique: true
  end

  add_foreign_key "activity_suggestions", "events"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "invitations", "events"
  add_foreign_key "invitations", "users", column: "invitee_id"
  add_foreign_key "match_votes", "events"
  add_foreign_key "match_votes", "invitations"
  add_foreign_key "preferences", "invitations"
end
