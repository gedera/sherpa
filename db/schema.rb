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

ActiveRecord::Schema.define(version: 2020_02_09_171355) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.string "file_name"
    t.integer "year"
    t.string "quality"
    t.integer "state"
    t.string "telegram_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tv_shows", force: :cascade do |t|
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
