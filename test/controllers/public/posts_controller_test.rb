require "test_helper"

class Public::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get public_posts_new_url
    assert_response :success
  end

  test "should get show" do
    get public_posts_show_url
    assert_response :success
  end

  test "should get index" do
    get public_posts_index_url
    assert_response :success
  end

  test "should get draft" do
    get public_posts_draft_url
    assert_response :success
  end

  test "should get nice" do
    get public_posts_nice_url
    assert_response :success
  end

  test "should get edit" do
    get public_posts_edit_url
    assert_response :success
  end
end
