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

  timestamps!

  save_callback :before, :slugify
  save_callback :before, :clear_cache
  save_callback :before, :published_date_check

  def self.latest_post
    post = CACHE.get("content_latest_post")
    return post unless post.nil?
    post = Content.paginate(:design_doc => 'Content', :view_name => 'by_public_posts',
      :per_page => 10, :page => 1, :descending => true, :include_docs => true)[0]
    CACHE.write("content_latest_post", post)
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
    Comment.by_content_id(:key => id, :descending => false)
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
    CACHE.delete("content_latest_post")
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
