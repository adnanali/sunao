require 'test_helper'

class Admin::ContentTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_content_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create content_type" do
    assert_difference('Admin::ContentType.count') do
      post :create, :content_type => { }
    end

    assert_redirected_to content_type_path(assigns(:content_type))
  end

  test "should show content_type" do
    get :show, :id => admin_content_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_content_types(:one).to_param
    assert_response :success
  end

  test "should update content_type" do
    put :update, :id => admin_content_types(:one).to_param, :content_type => { }
    assert_redirected_to content_type_path(assigns(:content_type))
  end

  test "should destroy content_type" do
    assert_difference('Admin::ContentType.count', -1) do
      delete :destroy, :id => admin_content_types(:one).to_param
    end

    assert_redirected_to admin_content_types_path
  end
end
