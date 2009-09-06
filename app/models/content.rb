class Content < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :type
  property :title
  property :body
  property :slug
  property :published_date
  
  property :public

  view_by :slug
  view_by :type

  timestamps!

  save_callback :before, :slugify
  save_callback :before, :published_date_check

  protected
  def slugify
    self['slug'] = title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'') if self['slug'].blank?
  end

  def published_date_check
    RAILS_DEFAULT_LOGGER.info self['public'].type
    self['published_date'] = Time.now if self['public'] == '1' and self['published_date'].blank?
  end
end