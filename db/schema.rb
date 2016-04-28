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

ActiveRecord::Schema.define(version: 20160425210208) do

  create_table "administers", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_tj_popular_ranks", force: :cascade do |t|
    t.string   "symd"
    t.string   "eymd"
    t.integer  "song_rank"
    t.integer  "song_num"
    t.string   "song_title"
    t.string   "song_singer"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "interval_keys", force: :cascade do |t|
    t.string   "key"
    t.integer  "keyNum"
    t.float    "percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "songs", force: :cascade do |t|
    t.string   "title"
    t.string   "artist"
    t.string   "lowkey"
    t.string   "highkey"
    t.text     "tjnum"
    t.text     "gininum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
