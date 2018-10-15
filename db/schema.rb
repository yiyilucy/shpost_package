# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181012011532) do

  create_table "businesses", force: true do |t|
    t.string   "name",       default: "", null: false
    t.string   "start_date"
    t.string   "end_date"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret_key"
  end

  create_table "import_files", force: true do |t|
    t.string   "file_name",                   null: false
    t.string   "file_path",   default: "",    null: false
    t.datetime "import_date"
    t.integer  "user_id"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.boolean  "is_process",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_infos", force: true do |t|
    t.string   "registration_no"
    t.string   "postcode"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interface_senders", force: true do |t|
    t.string   "url"
    t.string   "host"
    t.string   "port"
    t.string   "interface_type"
    t.string   "http_type"
    t.string   "callback_class"
    t.string   "callback_method"
    t.text     "callback_params"
    t.string   "status"
    t.integer  "send_times"
    t.datetime "next_time"
    t.text     "body"
    t.datetime "last_time"
    t.text     "last_response"
    t.string   "interface_code"
    t.integer  "max_times"
    t.integer  "interval"
    t.text     "error_msg"
    t.string   "object_class"
    t.integer  "object_id"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interface_senders", ["business_id"], name: "index_interface_senders_on_business_id"
  add_index "interface_senders", ["created_at"], name: "index_interface_senders_on_created_at"
  add_index "interface_senders", ["object_id"], name: "index_interface_senders_on_object_id"
  add_index "interface_senders", ["status"], name: "index_interface_senders_on_status"
  add_index "interface_senders", ["unit_id"], name: "index_interface_senders_on_unit_id"

  create_table "query_results", force: true do |t|
    t.string   "source"
    t.string   "registration_no", null: false
    t.string   "postcode"
    t.datetime "order_date"
    t.datetime "query_date"
    t.string   "result"
    t.string   "status"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "unit_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.string   "name"
    t.string   "desc"
    t.string   "no"
    t.string   "short_name"
    t.string   "tcbd_khdh"
    t.integer  "level"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "user_logs", force: true do |t|
    t.integer  "user_id",            default: 0,  null: false
    t.string   "operation",          default: "", null: false
    t.string   "object_class"
    t.integer  "object_primary_key"
    t.string   "object_symbol"
    t.string   "desc"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",               default: "", null: false
    t.string   "role",                   default: "", null: false
    t.string   "name"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
