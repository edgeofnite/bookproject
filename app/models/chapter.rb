# == Schema Information
# Schema version: 20090608135958
#
# Table name: chapters
#
#  id        :integer         not null, primary key
#  author_id :integer         not null
#  book_id   :integer         not null
#  due_date  :date
#  contents  :binary
#  title     :string(100)
#  finished  :boolean
#  edited    :boolean
#  number    :integer         not null
#  comment   :text
#  state     :string(255)     default("new"), not null
#

class Chapter < ActiveRecord::Base
  validates_numericality_of :author_id, :number, :book_id, :only_integer => true
  validates_presence_of :due_date
  belongs_to :user, :foreign_key => :author_id
  belongs_to :book

  #### Constants for the :status field of a chapter.
  # Chapter State Transitions: (Transitions are not monotonic) [ chapter.status ]
  #  Writing: - The "owner" is writing this chapter
  #  Editing: - The "owner" has finished writing and the editor now owns this chapter
  #  Accepted: - The editor accepts this chapter and passes the book on to the next chapter writer
  #	 Rejected: - The editor rejects this chapter and returns the book to the previous writer.

  state_machine :state, :initial => :new do
    event :begin_writing do
      transition :new => :writing, :editing => :rejected
    end

    event :begin_editing do
      transition :writing => :editing, :rejected => :editing
    end

    # the accepted to accepted link is if someone re-edits a completed chapter
    event :done_editing do
      transition :editing => :accepted, :accepted => :accepted
    end
  end

  def editor
    return self.book.editor
  end

  # Return true if this user can write this chapter
  def user_can_write(user)
    if (self.writing? or self.rejected?) and (self.user == user or self.book.project.owner == user or user.id == 1) then
      return true
    else
      return false
    end
  end

  # Return true if this user can edit this chapter
  def user_can_edit(user)
    if (self.editor == user) or self.book.project.owner == user or user.id == 1 then
      return true
    else
      return false
    end
  end

  # Taken from http://gist.github.com/139987
  # This function takes messy Word HTML pasted into a WYSIWYG and cleans it up
  # It leaves the tags and attributes specified in the params
  # Copyright (c) 2009, Radio New Zealand
  # Released under the MIT license

  def clean_up_contents()
    # very minimal
    # elements = ['p', 'b', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'], attributes={})

    if self.contents?
      html = self.contents
      email_regex = /<p>Email:\s+((\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,})/i

      html.gsub! /\[endif\]--/  , ''
      html.gsub! /[\n|\r]/    , ' '
      html.gsub! /&nbsp;/     , ' '

      # this will convert UNICODE into ASCII.  
      #It will also strip any possiblity of using a foreign language!
      #converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8') 
      #html = converter.iconv(html).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
      # keep only the things we want.
      unless (Sanitize::Config::RELAXED[:attributes]["table"].include?("align"))
        Sanitize::Config::RELAXED[:attributes]["table"] << "align"
      end

      config = Sanitize::Config::RELAXED
      if (html.encoding.name == 'ASCII-8BIT')
        config[:output_encoding] = 'ASCII'
      end
      html = Sanitize.clean( html, config)

      # butt up any tags
      html.gsub! />\s+</                  , '><'

      #remove email address lines
      html.gsub! email_regex              , '<p>'

      # post sanitize cleanup of empty blocks
      # the order of removal is import - this is the way word stacks these elements
      html.gsub! /<i><\/i>/               , ''
      html.gsub! /<b><\/b>/               , ''
      html.gsub! /<\/b><b>/               , ''
      html.gsub! /<p><\/p>/               , ''
      html.gsub! /<p><b><\/b><\/p>/       , ''

      # misc - fix butted times
      html.gsub! /(\d)am /          , '\1 am '
      html.gsub! /(\d)pm /          , '\1 pm '
      # misc - remove multiple space that may cause doc specific regexs to fail (in dates for example)
      html.gsub! /\s+/                  , ' '

      # add new lines at the end of lines
      html.gsub! /<\/(p|h\d|dt|dd|dl)>/, '</\1>' + "\n"
      html.gsub! /<dl>/             , '<dl>' + "\n"

      self.contents = html
    end
  end


end
