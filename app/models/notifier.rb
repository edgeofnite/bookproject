class Notifier < ActionMailer::Base

  # The chapter is now ready to be edited
  def chapter_writing_complete(chapter, sent_at = Time.now)
    # This will read the file views/notifier/chapter_writing_complete.erb
    subject    "Chapter #{chapter.number} of book #{chapter.book.title} is read for editing"
    recipients chapter.book.editor.email
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
    recipients chapter.book.editor.email
    recipients "#{chapter.book.editor.username} <#{chapter.book.editor.email}>"
    from       "bookproject@jaffestrategies.com"
    sent_on    sent_at
    content_type = "text/plain"
    @chapter = chapter
  end

  def chapter_rewrite(chapter, sent_at = Time.now)
    subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
    recipients chapter.book.editor.email
    from       "bookproject@jaffestrategies.com"
    sent_on    sent_at
    content_type = "text/plain"
    @chapter = chapter
  end

  def new_chapter_to_write(chapter, sent_at = Time.now)
    recipients  chapter.user.email
    subject    "Chapter #{chapter.number} of book #{chapter.book.title}"
    from       "bookproject@jaffestrategies.com"
    sent_on    sent_at
    content_type = "text/plain"
    @chapter = chapter
  end

end
