require 'test_helper'

class ProjectControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  me = "I am bob"
  def setUp()
    User.create(:aboutMe => me, :username => "bob", :password =>"aaa")
  end
  def tearDown()
    user = User.find_by_username("bob")
    user.destroy
  end
  
  test "the truth" do
    assert true
  end
end
