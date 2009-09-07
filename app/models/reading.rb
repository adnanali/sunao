class Reading < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :title
  property :slug

  property :reading_language

  property :description
  
  property :words

  property :source

  property :author
  property :author_id
  
  property :published_date
  
  property :user_id

  property :public

  view_by :slug
  view_by :user_id
  view_by :public
  view_by :author

  timestamps!

  save_callback :before, :slugify
  save_callback :before, :published_date_check

  def permalink
    self.slug
  end

  def user
    User.get(user_id)
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
  def slugify
    slugme = title + " " + author + " " + user.display_name
    self['slug'] = slugme.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'')
  end

  def published_date_check
    self['published_date'] = Time.now if self['public'] == '1' and self['published_date'].blank?
  end
end
