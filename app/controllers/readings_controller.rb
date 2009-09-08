class ReadingsController < ApplicationController
  
  def index
    @readings = Reading.all
    @readings.sort! { |b,a| a.created_at <=> b.created_at }

    respond_to do |format|
      format.html 
    end
  end

  def show
    @reading = Reading.by_slug(:key => params[:id])[0]
    filename = params[:filename][0]

    if params[:filename]
      metadata = @reading['_attachments'][filename]
      data = @reading.read_attachment(filename)
      send_data(data, {
        :filename => filename,
        :type => 'audio/mpeg', #metadata['content_type'],
        :disposition => "inline",
      })
      return
    end

    respond_to do |format|
      format.html
    end
  end
end
