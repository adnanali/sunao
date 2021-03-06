class ContentController < ApplicationController
  def show
    @content = Content.by_slug(:key => params[:id].join("/"))[0]

    @content['view_single'] = true

    @comments = @content.comments
    @comments.sort! { |a,b| a.created_at <=> b.created_at }
    @comment = Comment.new(:content_id => @content.id)

    @content_for_title = @content.title + " -- "
    
    respond_to do |format|
      format.html
    end
  end
end
