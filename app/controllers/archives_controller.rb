class ArchivesController < ApplicationController

  def index
    @contents = Content.by_type :key => "post"
    @contents.sort! { |b,a| a.published_at <=> b.published_at}

    respond_to do |format|
      format.html 
    end
  end

end
