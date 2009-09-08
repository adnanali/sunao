class ReadingsController < ApplicationController
  before_filter :need_login, :except => [:show]
  
  def index
    @readings = Reading.all
    @readings.sort! { |b,a| a.created_at <=> b.created_at }

    respond_to do |format|
      format.html 
    end
  end

  def show
    @reading = Reading.by_slug(:key => params[:id])[0]

    if params[:filename]
      metadata = @reading['_attachments'][params[:filename]]
      data = @reading.read_attachment(params[:filename])
      send_data(data, {
        :filename => params[:filename],
        :type => metadata['content_type'],
        :disposition => "inline",
      })
      return
    end

    respond_to do |format|
      format.html
    end
  end

  def edit
    @reading = Reading.get(params[:id])
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
        format.html { redirect_to(admin_reading_path(@reading.id)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    params[:reading][:words] = {}
    params[:reading][:words_language].each_with_index do |lang, i|
      params[:reading]['words'][lang] = params[:reading][:words_body][i]
    end
    params[:reading].delete('words_language')
    params[:reading].delete('words_body')
    
    @reading = Reading.get(params[:id])

    respond_to do |format|
      if @reading.update_attributes(params[:reading])
        flash[:notice] = 'ReadingType was successfully updated.'
        format.html { redirect_to(admin_reading_path @reading.id) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @reading = Reading.get(params[:id])
    @reading.destroy

    respond_to do |format|
      format.html { redirect_to(admin_reading_index_url) }
      #format.xml  { head :ok }
    end
  end

end
