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

ActiveRecord::Schema.define(version: 2020_05_24_013656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "components", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.string "components", limit: 255
    t.text "recipe_ids"
    t.text "image"
    t.integer "list"
    t.string "nick", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255
    t.string "pseudonyms_as_markdown", limit: 255
    t.boolean "never_make_me_tall"
    t.text "list_as_markdown"
    t.string "tags_as_text"
    t.text "subtitle"
    t.text "substitutes_as_markdown"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "content_as_markdown"
    t.text "element_ids"
    t.integer "component"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255
    t.string "image", limit: 255
    t.boolean "never_make_me_tall"
  end

  create_table "pseudonyms", id: :serial, force: :cascade do |t|
    t.integer "pseudonymable_id"
    t.string "pseudonymable_type", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "recipe"
    t.text "description"
    t.string "image", limit: 255
    t.text "component_ids"
    t.boolean "published"
    t.datetime "last_updated"
    t.text "instructions"
    t.string "list_ids", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255
    t.text "stored_recipe_as_html"
    t.boolean "featured"
    t.boolean "never_make_me_tall"
    t.integer "rating"
    t.text "adapted_from"
    t.string "tags_as_text"
    t.text "image2"
    t.text "image3"
    t.text "subtitle"
  end

  create_table "relationships", id: :serial, force: :cascade do |t|
    t.integer "relatable_id"
    t.string "relatable_type", limit: 255
    t.integer "child_id"
    t.string "child_type", limit: 255
    t.string "field", limit: 255
    t.string "key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["relatable_id", "relatable_type"], name: "index_relationships_on_relatable_id_and_relatable_type"
  end

  create_table "subcomponents", force: :cascade do |t|
    t.bigint "component_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "index"
    t.index ["component_id"], name: "index_subcomponents_on_component_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "subcomponents", "components"
  add_foreign_key "taggings", "tags"
end
