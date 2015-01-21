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

ActiveRecord::Schema.define(version: 20150120051148) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aliases", force: true do |t|
    t.integer  "component_id"
    t.text     "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "aliases", ["component_id"], name: "index_aliases_on_component_id", using: :btree

  create_table "components", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "components"
    t.text     "recipe_ids"
    t.text     "image"
    t.integer  "list"
    t.string   "nick"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "akas"
    t.string   "aka_id"
    t.string   "akas_as_markdown"
    t.boolean  "never_make_me_tall"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "lists", force: true do |t|
    t.string   "name"
    t.text     "content_as_markdown"
    t.text     "element_ids"
    t.integer  "component"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "image"
    t.boolean  "never_make_me_tall"
  end

  create_table "recipes", force: true do |t|
    t.string   "name"
    t.text     "recipe"
    t.text     "description"
    t.string   "image"
    t.text     "component_ids"
    t.boolean  "published"
    t.datetime "last_updated"
    t.text     "instructions"
    t.string   "list_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "stored_recipe_as_html"
    t.boolean  "featured"
    t.text     "recommends"
    t.boolean  "never_make_me_tall"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
