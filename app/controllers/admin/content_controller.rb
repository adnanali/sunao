class Admin::ContentController < ApplicationController
  before_filter :need_admin
  
  def index
    @contents = Content.all
    @contents.sort! { |b,a| a.created_at <=> b.created_at }

    respond_to do |format|
      format.html 
    end
  end

  def show
    @content = Content.get(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def edit
    @content = Content.get(params[:id])    
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(params[:content])

    @content.user_id = current_user.id

    respond_to do |format|
      if @content.save
        flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to(admin_content_path(@content.id)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @content = Content.get(params[:id])

    respond_to do |format|
      if @content.update_attributes(params[:content])
        flash[:notice] = 'ContentType was successfully updated.'
        format.html { redirect_to(admin_content_path @content.id) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @content = Content.get(params[:id])
    @content.destroy

    respond_to do |format|
      format.html { redirect_to(admin_content_index_url) }
      #format.xml  { head :ok }
    end
  end

end
