class Content < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :type
  property :title
  property :body
  property :slug
  
  property :public

  view_by :slug
  view_by :type

  timestamps!

  save_callback :before, :slugify

  def slugify
    self['slug'] = title.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'') if self['slug'].blank?
  end
end