class SubmissionsController < ApplicationController
  before_filter :need_login
  
  def index
    render :action => :new
  end

  def show
    @reading = Reading.get(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def new
    @reading = Reading.new
  end

  def create
    params[:reading][:words] = {}
    params[:reading][:words_language].each_with_index do |lang, i|
      params[:reading]['words'][lang] = params[:reading][:words_body][i]
    end
    params[:reading].delete('words_language')
    params[:reading].delete('words_body')
    
    @reading = Reading.new(params[:reading])

    @reading.user_id = current_user.id

    respond_to do |format|
      if @reading.save
        flash[:notice] = 'Reading was successfully created.'
        format.html { redirect_to(submission_path(@reading.id)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
