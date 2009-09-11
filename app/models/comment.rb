class Comment < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :name
  property :link
  property :email
  property :body
  property :content_id
  property :user_id

  view_by :content_id
  view_by :user_id

  validates_present :name, :email, :body, :content_id
  #validates_format :email, :format => :email_address
  #

  def http 
    (link =~ /^http:\/\//) ? link : "http://#{link}"
  end
  timestamps!
end
