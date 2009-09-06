class PagesController < ApplicationController
  def index
    @content = Content.by_type(:key => "post").paginate(:page => 1, :per_page => 1)[0]

    render "content/show"
  end
end
