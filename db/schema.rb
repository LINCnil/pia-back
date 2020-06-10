# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_12_135402) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", id: :serial, force: :cascade do |t|
    t.string "reference_to", null: false
    t.jsonb "data", default: {}
    t.integer "pia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pia_id"], name: "index_answers_on_pia_id"
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "attached_file"
    t.boolean "pia_signed", default: false
    t.integer "pia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.index ["pia_id"], name: "index_attachments_on_pia_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "description", default: ""
    t.string "reference_to", null: false
    t.boolean "for_measure", default: false
    t.integer "pia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pia_id"], name: "index_comments_on_pia_id"
  end

  create_table "evaluations", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "reference_to", null: false
    t.text "action_plan_comment", default: ""
    t.text "evaluation_comment", default: ""
    t.datetime "evaluation_date"
    t.jsonb "gauges", default: {}
    t.datetime "estimated_implementation_date"
    t.string "person_in_charge", default: ""
    t.integer "pia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "global_status", default: 0
    t.index ["pia_id"], name: "index_evaluations_on_pia_id"
  end

  create_table "measures", id: :serial, force: :cascade do |t|
    t.string "title", default: ""
    t.text "content", default: ""
    t.text "placeholder", default: ""
    t.integer "pia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pia_id"], name: "index_measures_on_pia_id"
  end

  create_table "pias", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "name", null: false
    t.string "author_name", default: ""
    t.string "evaluator_name", default: ""
    t.string "validator_name", default: ""
    t.integer "dpo_status", default: 0
    t.text "dpo_opinion", default: ""
    t.text "concerned_people_opinion", default: ""
    t.integer "concerned_people_status", default: 0
    t.text "rejection_reason", default: ""
    t.text "applied_adjustments", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dpos_names", default: ""
    t.string "people_names", default: ""
    t.integer "is_example", default: 0
    t.boolean "concerned_people_searched_opinion", default: false
    t.string "concerned_people_searched_content"
    t.integer "structure_id"
    t.string "structure_name"
    t.string "structure_sector_name"
    t.jsonb "structure_data"
    t.boolean "is_archive", default: false, null: false
    t.string "category"
    t.index ["structure_id"], name: "index_pias_on_structure_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.jsonb "export", null: false
    t.bigint "pia_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pia_id"], name: "index_revisions_on_pia_id"
  end

  create_table "structures", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "sector_name", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answers", "pias"
  add_foreign_key "attachments", "pias"
  add_foreign_key "comments", "pias"
  add_foreign_key "evaluations", "pias"
  add_foreign_key "measures", "pias"
  add_foreign_key "pias", "structures"
  add_foreign_key "revisions", "pias"
end
