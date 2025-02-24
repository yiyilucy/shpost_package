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

ActiveRecord::Schema.define(version: 20240914053339) do

  create_table "businesses", force: true do |t|
    t.string   "name",        default: "",    null: false
    t.integer  "start_date"
    t.integer  "end_date"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret_key"
    t.string   "send_id"
    t.string   "no"
    t.integer  "keep_days"
    t.string   "secret_key1"
    t.boolean  "local_first", default: false
  end

  create_table "import_files", force: true do |t|
    t.string   "file_name",                                      null: false
    t.string   "file_path",                  default: "",        null: false
    t.datetime "import_date"
    t.integer  "user_id"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.string   "status",                     default: "waiting"
    t.string   "desc",          limit: 4000
    t.string   "err_file_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "import_type"
    t.boolean  "is_query"
    t.boolean  "is_update"
    t.integer  "total_rows",                 default: 0
    t.integer  "finish_rows",                default: 0
    t.string   "fetch_status",               default: "waiting"
  end

  create_table "interface_infos", force: true do |t|
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "request_body"
    t.text     "response_body"
    t.text     "params"
    t.string   "business_id"
    t.string   "unit_id"
    t.string   "request_ip"
    t.string   "status"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.string   "business_code"
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
    t.string   "header"
    t.string   "business_code"
  end

  add_index "interface_senders", ["business_code"], name: "index_interface_senders_on_business_code"
  add_index "interface_senders", ["business_id"], name: "index_interface_senders_on_business_id"
  add_index "interface_senders", ["created_at"], name: "index_interface_senders_on_created_at"
  add_index "interface_senders", ["object_id"], name: "index_interface_senders_on_object_id"
  add_index "interface_senders", ["status"], name: "index_interface_senders_on_status"
  add_index "interface_senders", ["unit_id"], name: "index_interface_senders_on_unit_id"

  create_table "pkp_waybill_base_locals", force: true do |t|
    t.integer  "pkp_waybill_id"
    t.integer  "order_id"
    t.string   "logistics_order_no"
    t.string   "inner_channel"
    t.integer  "base_product_id"
    t.string   "base_product_no"
    t.string   "base_product_name"
    t.integer  "biz_product_id"
    t.string   "biz_product_no"
    t.string   "biz_product_name"
    t.string   "product_type"
    t.string   "product_reach_area"
    t.string   "contents_attribute"
    t.string   "cmd_code"
    t.string   "manual_charge_reason"
    t.string   "time_limit"
    t.string   "io_type"
    t.string   "ecommerce_no"
    t.string   "waybill_type"
    t.string   "waybill_no"
    t.string   "pre_waybill_no"
    t.datetime "biz_occur_date"
    t.integer  "post_org_id"
    t.string   "post_org_no"
    t.string   "org_drds_code"
    t.string   "post_org_name"
    t.integer  "post_person_id"
    t.string   "post_person_no"
    t.string   "post_person_name"
    t.string   "post_person_mobile"
    t.string   "sender_type"
    t.integer  "sender_id"
    t.string   "sender_no"
    t.string   "sender"
    t.integer  "sender_warehouse_id"
    t.string   "sender_warehouse_name"
    t.string   "sender_linker"
    t.string   "sender_fixtel"
    t.string   "sender_mobile"
    t.string   "sender_im_type"
    t.string   "sender_im_id"
    t.string   "sender_id_type"
    t.string   "sender_id_no"
    t.string   "sender_id_encrypted_code"
    t.string   "sender_agent_id_type"
    t.string   "sender_agent_id_no"
    t.string   "sender_id_encrypted_code_agent"
    t.string   "sender_addr"
    t.string   "sender_addr_additional"
    t.string   "sender_country_no"
    t.string   "sender_country_name"
    t.string   "sender_province_no"
    t.string   "sender_province_name"
    t.string   "sender_city_no"
    t.string   "sender_city_name"
    t.string   "sender_county_no"
    t.string   "sender_county_name"
    t.string   "sender_district_no"
    t.string   "sender_postcode"
    t.string   "sender_gis"
    t.string   "sender_notes"
    t.string   "registered_customer_no"
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.string   "receiver_no"
    t.string   "receiver"
    t.integer  "receiver_warehouse_id"
    t.string   "receiver_warehouse_name"
    t.string   "receiver_linker"
    t.string   "receiver_im_type"
    t.string   "receiver_im_id"
    t.string   "receiver_fixtel"
    t.string   "receiver_mobile"
    t.string   "receiver_addr"
    t.string   "receiver_addr_additional"
    t.string   "receiver_country_no"
    t.string   "receiver_country_name"
    t.string   "receiver_province_no"
    t.string   "receiver_province_name"
    t.string   "receiver_city_no"
    t.string   "receiver_city_name"
    t.string   "receiver_county_no"
    t.string   "receiver_county_name"
    t.string   "receiver_district_no"
    t.string   "receiver_postcode"
    t.string   "receiver_gis"
    t.string   "receiver_notes"
    t.integer  "customer_manager_id"
    t.string   "customer_manager_no"
    t.string   "customer_manager_name"
    t.integer  "salesman_id"
    t.string   "salesman_no"
    t.string   "salesman_name"
    t.decimal  "order_weight",                   precision: 8,  scale: 0
    t.decimal  "real_weight",                    precision: 8,  scale: 0
    t.decimal  "fee_weight",                     precision: 8,  scale: 0
    t.decimal  "volume_weight",                  precision: 8,  scale: 0
    t.decimal  "volume",                         precision: 8,  scale: 0
    t.decimal  "length",                         precision: 8,  scale: 0
    t.decimal  "width",                          precision: 8,  scale: 0
    t.decimal  "height",                         precision: 8,  scale: 0
    t.integer  "quantity"
    t.string   "packaging"
    t.string   "package_material"
    t.string   "goods_desc"
    t.string   "contents_type_no"
    t.string   "contents_type_name"
    t.decimal  "contents_weight",                precision: 8,  scale: 0
    t.integer  "contents_quantity"
    t.string   "cod_flag"
    t.decimal  "cod_amount",                     precision: 12, scale: 2
    t.string   "receipt_flag"
    t.string   "receipt_waybill_no"
    t.decimal  "receipt_fee_amount",             precision: 12, scale: 2
    t.string   "insurance_flag"
    t.decimal  "insurance_amount",               precision: 12, scale: 2
    t.decimal  "insurance_premium_amount",       precision: 12, scale: 2
    t.string   "valuable_flag"
    t.string   "transfer_type"
    t.string   "pickup_type"
    t.string   "allow_fee_flag"
    t.string   "is_feed_flag"
    t.datetime "fee_date"
    t.decimal  "postage_total",                  precision: 12, scale: 2
    t.decimal  "postage_standard",               precision: 12, scale: 2
    t.decimal  "postage_paid",                   precision: 12, scale: 2
    t.decimal  "postage_other",                  precision: 12, scale: 2
    t.string   "payment_mode"
    t.decimal  "discount_rate",                  precision: 6,  scale: 2
    t.string   "settlement_mode"
    t.string   "payment_state"
    t.datetime "payment_date"
    t.string   "payment_id"
    t.string   "is_advance_flag"
    t.string   "deliver_type"
    t.string   "deliver_sign"
    t.string   "deliver_date"
    t.string   "deliver_notes"
    t.datetime "deliver_pre_date"
    t.string   "battery_flag"
    t.string   "workbench"
    t.string   "electronic_preferential_no"
    t.decimal  "electronic_preferential_amount", precision: 12, scale: 2
    t.string   "pickup_attribute"
    t.string   "adjust_type"
    t.decimal  "postage_revoke",                 precision: 12, scale: 2
    t.string   "print_flag"
    t.datetime "print_date"
    t.integer  "print_times"
    t.string   "is_deleted"
    t.integer  "create_user_id"
    t.datetime "gmt_created"
    t.integer  "modify_user_id"
    t.datetime "gmt_modified"
    t.string   "declare_source"
    t.string   "declare_type"
    t.string   "declare_curr_code"
    t.string   "reserved1"
    t.string   "reserved2"
    t.string   "reserved3"
    t.string   "reserved4"
    t.string   "reserved5"
    t.string   "reserved6"
    t.string   "reserved7"
    t.string   "reserved8"
    t.datetime "reserved9"
    t.text     "reserved10"
    t.integer  "query_result_id"
    t.string   "created_day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pkp_waybill_base_locals", ["created_day"], name: "index_pkp_waybill_base_locals_on_created_day"
  add_index "pkp_waybill_base_locals", ["query_result_id"], name: "index_pkp_waybill_base_locals_on_query_result_id"
  add_index "pkp_waybill_base_locals", ["sender_no"], name: "index_pkp_waybill_base_locals_on_sender_no"
  add_index "pkp_waybill_base_locals", ["waybill_no"], name: "index_pkp_waybill_base_locals_on_waybill_no"

  create_table "qr_attrs", force: true do |t|
    t.datetime "data_date"
    t.datetime "batch_date"
    t.string   "lmk"
    t.string   "id_code"
    t.string   "sn"
    t.string   "issue_bank"
    t.string   "name"
    t.string   "bank_no"
    t.string   "phone"
    t.string   "address"
    t.integer  "query_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "id_num"
    t.string   "province"
    t.string   "city"
    t.string   "district"
    t.decimal  "weight",          precision: 10, scale: 2
    t.decimal  "price",           precision: 10, scale: 2
    t.string   "branch_no"
    t.string   "branch_name"
    t.string   "match_branch"
    t.integer  "mistake_num"
  end

  add_index "qr_attrs", ["query_result_id"], name: "index_qr_attrs_on_query_result_id", unique: true

  create_table "query_result_import_files", force: true do |t|
    t.integer  "query_result_id"
    t.integer  "import_file_id"
    t.boolean  "is_sent",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "query_result_import_files", ["query_result_id"], name: "index_query_result_import_files_on_query_result_id"

  create_table "query_results", force: true do |t|
    t.string   "source"
    t.string   "registration_no",                     null: false
    t.string   "postcode"
    t.datetime "order_date"
    t.datetime "query_date"
    t.string   "result"
    t.string   "status",          default: "waiting"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "operated_at"
    t.string   "business_code"
    t.boolean  "is_posting"
    t.boolean  "is_sent"
    t.boolean  "to_send"
    t.integer  "import_file_id"
  end

  add_index "query_results", ["business_id"], name: "index_query_results_on_business_id"
  add_index "query_results", ["order_date"], name: "index_query_results_on_order_date"
  add_index "query_results", ["registration_no"], name: "index_query_results_on_registration_no", unique: true
  add_index "query_results", ["status"], name: "index_query_results_on_status"
  add_index "query_results", ["unit_id"], name: "index_query_results_on_unit_id"

  create_table "return_reasons", force: true do |t|
    t.string   "reason"
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "return_results", force: true do |t|
    t.string   "source"
    t.string   "registration_no", null: false
    t.string   "postcode"
    t.datetime "order_date"
    t.datetime "query_date"
    t.datetime "operated_at"
    t.string   "result"
    t.string   "status"
    t.integer  "unit_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "query_result_id"
    t.string   "reason"
    t.integer  "user_id"
  end

  add_index "return_results", ["registration_no"], name: "index_return_results_on_registration_no", unique: true

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pkp"
  end

  add_index "units", ["name"], name: "index_units_on_name", unique: true

  create_table "up_downloads", force: true do |t|
    t.string   "name"
    t.string   "use"
    t.string   "desc"
    t.string   "ver_no"
    t.string   "url"
    t.datetime "oper_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "locked_at"
    t.integer  "failed_attempts",        default: 0
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
