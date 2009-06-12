# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090605083306) do

  create_table "books", :force => true do |t|
    t.string  "title",       :limit => 100,                    :null => false
    t.text    "keywords"
    t.boolean "published",                  :default => false, :null => false
    t.integer "cur_chapter",                :default => 1,     :null => false
    t.integer "chapters",                   :default => 8,     :null => false
    t.integer "uber_id",                                       :null => false
    t.integer "project_id",                                    :null => false
  end

  create_table "chapters", :force => true do |t|
    t.integer "author_id",                                   :null => false
    t.integer "book_id",                                     :null => false
    t.date    "due_date"
    t.binary  "contents"
    t.string  "title",     :limit => 100
    t.boolean "finished",                 :default => false
    t.boolean "edited",                   :default => false
    t.integer "number",                                      :null => false
    t.text    "comment"
    t.string  "state",                    :default => "new", :null => false
  end

  create_table "groups", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "project_id", :null => false
  end

  create_table "projects", :force => true do |t|
    t.date    "signing_date"
    t.integer "days_per_chapter", :default => 7, :null => false
    t.integer "chapters",         :default => 8, :null => false
    t.integer "status",           :default => 0
    t.string  "name"
    t.integer "owner_id",         :default => 1
    t.boolean "private"
    t.integer "max_writers"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "ubers", :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "project_id"
  end

  create_table "users", :force => true do |t|
    t.string  "username",        :limit => 20, :null => false
    t.string  "hashed_password", :limit => 30, :null => false
    t.integer "age"
    t.string  "aboutMe"
    t.string  "salt"
    t.string  "email"
  end

end
