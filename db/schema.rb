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

ActiveRecord::Schema[7.0].define(version: 2023_10_01_000003) do
  create_table "cells", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "row", null: false
    t.integer "col", null: false
    t.boolean "is_mine", default: false, null: false
    t.string "state", default: "hidden", null: false
    t.integer "neighbor_mines", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "row", "col"], name: "index_cells_on_game_id_and_row_and_col", unique: true
    t.index ["game_id"], name: "index_cells_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "difficulty", default: "beginner", null: false
    t.integer "rows", null: false
    t.integer "cols", null: false
    t.integer "mines", null: false
    t.string "state", default: "playing", null: false
    t.integer "clicks", default: 0, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scores", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "player_name", null: false
    t.integer "time_taken", null: false
    t.integer "clicks", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "difficulty", default: "beginner", null: false
    t.index ["difficulty"], name: "index_scores_on_difficulty"
    t.index ["game_id"], name: "index_scores_on_game_id"
  end

  add_foreign_key "cells", "games"
  add_foreign_key "scores", "games"
end
