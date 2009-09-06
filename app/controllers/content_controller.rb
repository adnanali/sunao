class ContentController < ApplicationController
  def show
    @content = Content.by_slug(:key => params[:id].join("/"))[0]

    @content['view_single'] = true

    @comments = Comment.by_content_id(:key => @content.id, :descending => false)
    @comments.sort! { |a,b| a.created_at <=> b.created_at }
    @comment = Comment.new(:content_id => @content.id)
    
    respond_to do |format|
      format.html
    end
  end
end
