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

ActiveRecord::Schema[8.0].define(version: 2025_07_26_130557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "mobile_accesses", force: :cascade do |t|
    t.string "server_token"
    t.string "app_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "client_token"
    t.text "fcm_json_key"
    t.string "fcm_project_id"
  end

  create_table "mobile_devices", force: :cascade do |t|
    t.string "device_token"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_info"
    t.string "device_info"
    t.string "external_key"
    t.bigint "mobile_access_id"
    t.index ["external_key", "device_token", "mobile_access_id"], name: "index_mobile_devices_on_unique_combination", unique: true
    t.index ["external_key"], name: "index_mobile_devices_on_external_key"
    t.index ["mobile_access_id"], name: "index_mobile_devices_on_mobile_access_id"
  end

  create_table "mobile_users", force: :cascade do |t|
    t.text "device_group_token"
    t.text "topics", default: ["general"], array: true
    t.string "external_key", default: ""
    t.bigint "mobile_access_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_key", "mobile_access_id"], name: "index_mobile_users_on_unique_combination", unique: true
    t.index ["mobile_access_id"], name: "index_mobile_users_on_mobile_access_id"
  end

  add_foreign_key "mobile_devices", "mobile_accesses"
  add_foreign_key "mobile_users", "mobile_accesses"
end
