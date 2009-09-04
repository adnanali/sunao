class ContentController < ApplicationController
  def show
    @content = Content.by_slug(:key => params[:id].join("/"))[0]

    respond_to do |format|
      format.html
    end
  end
end
