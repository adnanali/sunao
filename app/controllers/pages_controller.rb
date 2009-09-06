class PagesController < ApplicationController
  def index
    @content = Content.latest_post
    #  Content.by_public_posts.paginate(:descending => true, :page => 1, :per_page => 1)[0]
    #Content.by_type(:key => "post").paginate(:descending => false, :page => 1, :per_page => 1)[0]

    render "content/show"
  end
end
