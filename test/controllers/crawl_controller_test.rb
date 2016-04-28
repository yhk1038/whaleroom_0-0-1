require 'test_helper'

class CrawlControllerTest < ActionController::TestCase
  test "should get tj_monthly_new" do
    get :tj_monthly_new
    assert_response :success
  end

  test "should get tj_monthly_popular" do
    get :tj_monthly_popular
    assert_response :success
  end

  test "should get tj_daily_popular" do
    get :tj_daily_popular
    assert_response :success
  end

end
