class Admin::UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format|
      format.html 
    end
  end

  def show
    @user = User.get(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def edit
    @user = User.get(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:content])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @user = User.get(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:content])
        flash[:notice] = 'UserType was successfully updated.'
        format.html { redirect_to(admin_user_path @user.id) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @user = User.get(params[:id])
    @user.destroy

    respond_to do |format|
      #format.html { redirect_to(admin_user_types_url) }
      #format.xml  { head :ok }
    end
  end

end
