class User < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :type
  property :name
  property :username
  property :display_name
  property :email
  property :openid

  timestamps!

  validates_present :type, :name, :username, :display_name

  view_by :username
  view_by :type

  save_callback :before, :set_type
  save_callback :before, :set_display_name

  def set_type
    self['type'] = 'user' if self['type'].blank?
  end

  def set_display_name
    self['display_name'] = self['username'] if self['display_name'].blank?
  end
end