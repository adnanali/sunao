class ArchivesController < ApplicationController

  def index
    @contents = Content.by_type :key => "post"
    @contents.sort! { |b,a| Time.parse(a.published_date) <=> Time.parse(b.published_date)}

    respond_to do |format|
      format.html 
    end
  end

end
