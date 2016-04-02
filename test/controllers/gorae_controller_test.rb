require 'test_helper'

class GoraeControllerTest < ActionController::TestCase
  test "should get entering" do
    get :entering
    assert_response :success
  end

end
