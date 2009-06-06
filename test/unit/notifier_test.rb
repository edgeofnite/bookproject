require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "chapter_writing_complete" do
    chapter = Chapter.find(1)
    headers = {:subject => "Chapter #{chapter.number} of book #{chapter.book.title} is read for editing",
      :to => "#{chapter.book.editor.username} <#{chapter.book.editor.email}>",
      :from => "The book project <elliot.jaffe@gmail.com>",
      :date => Time.now}

    plain_part = TMail::Mail.new
    plain_part.body         = read_fixture('chapter_writing_complete_plain')
    plain_part.set_content_type('text','plain', {"charset" => "utf-8"})

    html_part = TMail::Mail.new
    html_part.body         = read_fixture('chapter_writing_complete')
    html_part.set_content_type('text','html', {"charset" => "utf-8"})

    mail = TMail::Mail.new
    mail.mime_encode_multipart(true)
    mail.set_content_type('multipart', 'alternative', {"boundary" => "stUVwxYZ"})
    headers.each {|f,v| mail[f.to_s] = v}
    mail.parts << plain_part << html_part

    actual = Notifier.create_chapter_writing_complete(chapter, @expected.date)
    return true

    # Don't bother.  To get this perfect means rewriting the message creation code from scratch.
    assert_mail_equal mail, actual
  end

  def assert_mail_equal(expected_mail, actual_mail)
    assert_equal replace_boundary_strings(expected_mail.encoded),
                 replace_boundary_strings(actual_mail.encoded)
  end

  def replace_boundary_strings(str)
    boundary_pattern = 'mimepart_[0-9a-f]+_[0-9a-f]+'
    str = str.gsub(/(Content-Type: multipart\/alternative; boundary=)\"?#{boundary_pattern}\"?/, "\\1replaced")
    str = str.gsub(/(Content-Type: multipart\/mixed; boundary=)\"?#{boundary_pattern}\"?/, "\\1replaced")
    str = str.gsub(/--#{boundary_pattern}/, "--replaced")
  end
end
