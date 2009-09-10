class Content < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :type
  property :title
  property :body
  property :slug
  property :published_date
  property :user_id

  property :reading_id

  property :public

  view_by :slug
  view_by :type
  view_by :user_id
  view_by :public_posts,
    :map => 
      "function(doc) {
        if (doc['couchrest-type'] == 'Content' && doc['type'] == 'post' && doc['public'] == '1') {
          emit(Date.parse(doc.published_date), doc);
        }
      }"
  view_by :posts_date,
    :map =>
      "function(doc) {
        if (doc.type == 'post') {
          emit([doc.published_date, doc.slug], null);
        }
      }";

  timestamps!

  save_callback :before, :slugify
  save_callback :before, :clear_cache
  save_callback :before, :published_date_check

  def prev_post
    @prev_post ||= Content.paginate(:design_doc => 'Content', :view_name => 'by_posts_date',
      :per_page => 2, :page => 1, :descending => true, :include_docs => true, :startkey => [published_date, slug])[1]
  end

  def next_post
    @next_post ||= Content.paginate(:design_doc => 'Content', :view_name => 'by_posts_date',
                            :per_page => 2, :page => 1, :descending => false, :include_docs => true, :startkey => [published_date, slug])[1]
  end
  
  def self.latest_post
    post = CACHE.get("content_latest_post")
    return post unless post.nil?
    post = Content.paginate(:design_doc => 'Content', :view_name => 'by_public_posts',
      :per_page => 1, :page => 1, :descending => true, :include_docs => true)[0]
    CACHE.set("content_latest_post", post)
    post
  end

  def self.latest_posts
    post = CACHE.get("content_latest_posts")
    return post unless post.nil?
    post = Content.paginate(:design_doc => 'Content', :view_name => 'by_public_posts',
                            :per_page => 5, :page => 1, :descending => true, :include_docs => true)
    CACHE.set("content_latest_posts", post)
    post
  end

  def self.all_posts
    post = CACHE.get("content_all_posts")
    return post unless post.nil?
    post = Content.paginate(:design_doc => 'Content', :view_name => 'by_public_posts',
                            :per_page => 10000, :page => 1, :descending => true, :include_docs => true)
    CACHE.set("content_all_posts", post)
    post
  end

  def permalink
    self.slug
  end

  def user
    @user ||= User.get(user_id)
  end

  def reading
    @reading ||= Reading.get(reading_id)
  end

  def comments
    comments = Comment.by_content_id(:key => id, :descending => false)
    comments.sort! { |a,b| a.created_at <=> b.created_at }
  end

  def attachment=(attachment)
    if attachment.is_a?(Tempfile)
      attachment_filename = File.basename(attachment.original_filename)
      attachment_options = {
        :file => attachment,
        :name => attachment_filename,
        :content_type => attachment.content_type
      }
      if self.has_key?('_attachments') && self['_attachments'].has_key?(attachment_filename)
        update_attachment(attachment_options)
      else
        create_attachment(attachment_options)
      end
    end
  end

  protected
  def clear_cache
    if type == 'post'
      CACHE.delete("content_latest_post")
      CACHE.delete("content_latest_posts")
      CACHE.delete("content_all_posts")
    end
  end
  def slugify
    if self['slug'].blank?
      self['slug'] = title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'')
      self['slug'] = "#{type}-#{self['slug']}" if type != 'post' && type != 'page'
    end
  end

  def published_date_check
    RAILS_DEFAULT_LOGGER.info self['public'].type
    self['published_date'] = Time.now if self['public'] == '1' and self['published_date'].blank?
  end
end
