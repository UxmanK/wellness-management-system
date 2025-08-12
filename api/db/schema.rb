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

ActiveRecord::Schema[7.1].define(version: 2025_08_12_180621) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.string "api_id"
    t.bigint "client_id", null: false
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.string "status"
    t.string "external_id"
    t.datetime "last_synced_at"
    t.string "sync_status", default: "pending"
    t.text "sync_errors"
    t.index ["client_id"], name: "index_appointments_on_client_id"
    t.index ["external_id"], name: "index_appointments_on_external_id"
    t.index ["sync_status"], name: "index_appointments_on_sync_status"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.datetime "last_synced_at"
    t.string "sync_status", default: "pending"
    t.text "sync_errors"
    t.index ["external_id"], name: "index_clients_on_external_id"
    t.index ["sync_status"], name: "index_clients_on_sync_status"
  end

  add_foreign_key "appointments", "clients"
end
