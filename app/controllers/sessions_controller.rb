class SessionsController < ApplicationController
  def new
  end

  def create
    # session[:user_id] =

    respond_to do |format|
        #flash[:notice] = 'Content was successfully created.'
        #format.html { render :partial => @comment }
    end
  end

  def destroy
    reset_session
    
    respond_to do |format|
      format.html { redirect_to(admin_comment_index_url) }
    end
  end

end
