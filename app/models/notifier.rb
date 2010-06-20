class Notifier < ActionMailer::Base

# The chapter is now ready to be edited
def chapter_writing_complete(chapter, sent_at = Time.now)
# This will read the file views/notifier/chapter_writing_complete.erb
subject    "Chapter #{chapter.number} of book #{chapter.book.title} is read for editing"
recipients email_addresses(chapter.book.editor.email)
from       "bookproject@jaffestrategies.com"
sent_on    sent_at
content_type = "text/plain"
@chapter = chapter

#    content_type "multipart/alternative" 
#    part :content_type => "text/html", :body => render_message("chapter_writing_complete", {}) 
#    part :content_type => "text/plain", :body => render_message("chapter_writing_complete_plain", {}) 

end

def chapter_ready_to_write(chapter, sent_at = Time.now)
subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
recipients email_addresses(chapter.user.email)
from       "bookproject@jaffestrategies.com"
sent_on    sent_at
content_type = "text/plain"
@chapter = chapter
end

def chapter_rewrite(chapter, sent_at = Time.now)
subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
recipients email_addresses(chapter.user.email)
from       "bookproject@jaffestrategies.com"
sent_on    sent_at
content_type = "text/plain"
@chapter = chapter
end

def chapter_ok(chapter, sent_at = Time.now)
subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
recipients email_addresses(chapter.user.email)
from       "bookproject@jaffestrategies.com"
sent_on    sent_at
content_type = "text/plain"
@chapter = chapter
end

def new_chapter_to_write(chapter, sent_at = Time.now)
recipients  email_addresses(chapter.user.email)
subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
from       "bookproject@jaffestrategies.com"
    sent_on    sent_at
    content_type = "text/plain"
    @chapter = chapter
  end

  def recover_password(options)
    from "bookproject@jaffestrategies.com"
    recipients email_addresses(options[:email])
    subject "BookProject Password Recovery"
    content_type 'text/html'
 
    body :key => options[:key], :domain => options[:domain]
  end


  private

  # ActionMailer wants an array of addresses if there are multiples.
  # support a ; or , as an address divider
  def email_addresses(str)
    if (str.index(','))
       return str.split(',')
    elsif str.index(';')
       return str.split(';')
    else
       return str
    end
  end
end
