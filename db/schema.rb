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

ActiveRecord::Schema.define(version: 2019_05_06_213639) do

  create_table "tv_shows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "file_name"
    t.string "season"
    t.string "episode"
    t.string "date"
    t.string "quality"
    t.string "rss"
    t.boolean "moved_to_media", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["moved_to_media"], name: "index_tv_shows_on_moved_to_media"
  end

end
