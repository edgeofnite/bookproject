class ChapterObserver < ActiveRecord::Observer
  def after_transition_state_from_writing_to_editing(chapter, transition)
    puts "Received transition for #{chapter}"
    Notifier.deliver_chapter_writing_complete(chapter)
  end
  def after_transition_state_from_editing_to_writing(chapter, transition)
    puts "Received transition for #{chapter}"
    Notifier.deliver_chapter_rewrite(chapter)
  end
  def after_transition_state_from_editing_to_accepted(chapter, transition)
    puts "Received transition for #{chapter}"
    # If the next chapter exists and this chapter was overdue, then notify the writer that they can begin
    book = chapter.book
    next_chapter = book.chapters[chapter.number + 1]
    if next_chapter != nil and chapter.due_date < Date.today
      Notifier.deliver_chapter_ready_to_write(chapter)
    end
  end
end


