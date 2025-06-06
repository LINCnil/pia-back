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

ActiveRecord::Schema[8.0].define(version: 2025_04_08_145426) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.integer "reference_to", null: false
    t.jsonb "data", default: {}
    t.integer "pia_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["pia_id"], name: "index_answers_on_pia_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.boolean "pia_signed", default: false
    t.integer "pia_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "comment"
    t.index ["pia_id"], name: "index_attachments_on_pia_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "description", default: ""
    t.string "reference_to", null: false
    t.boolean "for_measure", default: false
    t.integer "pia_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["pia_id"], name: "index_comments_on_pia_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "evaluations", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "reference_to", null: false
    t.text "action_plan_comment", default: ""
    t.text "evaluation_comment", default: ""
    t.datetime "evaluation_date", precision: nil
    t.jsonb "gauges", default: {}
    t.datetime "estimated_implementation_date", precision: nil
    t.string "person_in_charge", default: ""
    t.integer "pia_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "global_status", default: 0
    t.index ["pia_id"], name: "index_evaluations_on_pia_id"
  end

  create_table "knowledge_bases", force: :cascade do |t|
    t.string "name", null: false
    t.string "author", null: false
    t.string "contributors", null: false
    t.boolean "is_example", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
  end

  create_table "knowledges", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug"
    t.string "filters"
    t.string "category"
    t.string "placeholder"
    t.text "description"
    t.integer "items", default: [], array: true
    t.bigint "knowledge_base_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["knowledge_base_id"], name: "index_knowledges_on_knowledge_base_id"
  end

  create_table "measures", id: :serial, force: :cascade do |t|
    t.string "title", default: ""
    t.text "content", default: ""
    t.text "placeholder", default: ""
    t.integer "pia_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["pia_id"], name: "index_measures_on_pia_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pias", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "name", null: false
    t.string "author_name", default: ""
    t.string "evaluator_name", default: ""
    t.string "validator_name", default: ""
    t.integer "dpo_status"
    t.text "dpo_opinion", default: ""
    t.text "concerned_people_opinion", default: ""
    t.integer "concerned_people_status"
    t.text "rejection_reason", default: ""
    t.text "applied_adjustments", default: ""
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "dpos_names", default: ""
    t.string "people_names", default: ""
    t.integer "is_example", default: 0
    t.boolean "concerned_people_searched_opinion"
    t.string "concerned_people_searched_content"
    t.integer "structure_id"
    t.string "structure_name"
    t.string "structure_sector_name"
    t.jsonb "structure_data"
    t.boolean "is_archive", default: false, null: false
    t.string "category"
    t.float "progress", default: 0.0
    t.integer "lock_version", default: 0, null: false
    t.index ["structure_id"], name: "index_pias_on_structure_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.jsonb "export", null: false
    t.bigint "pia_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pia_id"], name: "index_revisions_on_pia_id"
  end

  create_table "structures", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "sector_name", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
    t.boolean "is_technical_admin", default: false
    t.boolean "is_functional_admin", default: false
    t.boolean "is_user", default: false
    t.string "uuid"
    t.datetime "locked_at", precision: nil
    t.string "login"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_pias", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pia_id", null: false
    t.integer "role", default: 0, null: false
    t.index ["pia_id"], name: "index_users_pias_on_pia_id"
    t.index ["user_id", "pia_id", "role"], name: "index_users_pias_on_user_id_and_pia_id_and_role", unique: true
    t.index ["user_id"], name: "index_users_pias_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answers", "pias"
  add_foreign_key "attachments", "pias"
  add_foreign_key "comments", "pias"
  add_foreign_key "comments", "users", on_delete: :nullify
  add_foreign_key "evaluations", "pias"
  add_foreign_key "knowledges", "knowledge_bases"
  add_foreign_key "measures", "pias"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "pias", "structures"
  add_foreign_key "revisions", "pias"
  add_foreign_key "users_pias", "pias"
  add_foreign_key "users_pias", "users"
end
