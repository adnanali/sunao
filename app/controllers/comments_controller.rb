class CommentsController < ApplicationController
  before_filter :need_admin, :only => [:destroy]
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html 
    end
  end

  def show
    @comment = Comment.get(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def edit
    @comment = Comment.get(params[:id])
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(params[:comment])

    if logged_in?
      @comment.user_id = current_user.id
      @comment.email = current_user.email
      @comment.name = current_user.display_name
      @comment.link = current_user.link
    end

    respond_to do |format|
      if @comment.save
        #flash[:notice] = 'Content was successfully created.'
        format.js
        #format.html { render :partial => @comment }
      else
        format.js
        #format.html { render :action => "new" }
      end
    end
  end

  def update
    @comment = Comment.get(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:content])
        flash[:notice] = 'ContentType was successfully updated.'
        format.html { redirect_to(admin_comment_path @comment.id) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @comment = Comment.get(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(admin_comment_index_url) }
      format.js { render :text => "$('#comment-#{params[:id]}').remove()" }
    end
  end

end
