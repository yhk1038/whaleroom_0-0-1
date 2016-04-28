require 'test_helper'

class SongControllerTest < ActionController::TestCase
  test "should get song_save" do
    get :song_save
    assert_response :success
  end

  test "should get song_delete" do
    get :song_delete
    assert_response :success
  end

end
