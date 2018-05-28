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

ActiveRecord::Schema.define(version: 20180525222420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.string   "reference_to",              null: false
    t.jsonb    "data",         default: {}
    t.integer  "pia_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["pia_id"], name: "index_answers_on_pia_id", using: :btree
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "attached_file"
    t.boolean  "pia_signed",    default: false
    t.integer  "pia_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "comment"
    t.index ["pia_id"], name: "index_attachments_on_pia_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "description",  default: ""
    t.string   "reference_to",                 null: false
    t.boolean  "for_measure",  default: false
    t.integer  "pia_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["pia_id"], name: "index_comments_on_pia_id", using: :btree
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "status",                        default: 0
    t.string   "reference_to",                               null: false
    t.text     "action_plan_comment",           default: ""
    t.text     "evaluation_comment",            default: ""
    t.datetime "evaluation_date"
    t.jsonb    "gauges",                        default: {}
    t.datetime "estimated_implementation_date"
    t.string   "person_in_charge",              default: ""
    t.integer  "pia_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "global_status",                 default: 0
    t.index ["pia_id"], name: "index_evaluations_on_pia_id", using: :btree
  end

  create_table "measures", force: :cascade do |t|
    t.string   "title",       default: ""
    t.text     "content",     default: ""
    t.text     "placeholder", default: ""
    t.integer  "pia_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["pia_id"], name: "index_measures_on_pia_id", using: :btree
  end

  create_table "pias", force: :cascade do |t|
    t.integer  "status",                            default: 0
    t.string   "name",                                              null: false
    t.string   "author_name",                       default: ""
    t.string   "evaluator_name",                    default: ""
    t.string   "validator_name",                    default: ""
    t.integer  "dpo_status",                        default: 0
    t.text     "dpo_opinion",                       default: ""
    t.text     "concerned_people_opinion",          default: ""
    t.integer  "concerned_people_status",           default: 0
    t.text     "rejection_reason",                  default: ""
    t.text     "applied_adjustments",               default: ""
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "dpos_names",                        default: ""
    t.string   "people_names",                      default: ""
    t.integer  "is_example",                        default: 0
    t.boolean  "concerned_people_searched_opinion", default: false
    t.string   "concerned_people_searched_content"
  end

  add_foreign_key "answers", "pias"
  add_foreign_key "attachments", "pias"
  add_foreign_key "comments", "pias"
  add_foreign_key "evaluations", "pias"
  add_foreign_key "measures", "pias"
end
