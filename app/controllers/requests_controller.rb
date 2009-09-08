class RequestsController < ApplicationController
  before_filter :need_login, :only => [:create, :new]
  
  def index
    @contents = Content.by_type :key => "request"
    @contents.sort! { |b,a| a.created_at <=> b.created_at }

    respond_to do |format|
      format.html 
    end
  end

  def show
    @content = Content.get(params[:id])
    @content['view_single'] = true

    @comments = @content.comments
    @comment = Comment.new(:content_id => @content.id)
    respond_to do |format|
      format.html { render 'content/show' }
    end
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(params[:content])

    @content.user_id = current_user.id
    @content.public = '1'
    @content.type = 'request'

    respond_to do |format|
      if @content.save
        #flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to request_path(@content.id) }
      else
        format.js
        #format.html { render :action => "new" }
      end
    end
  end

end
