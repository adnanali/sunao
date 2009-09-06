class Comment < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :name
  property :link
  property :email
  property :body
  property :content_id

  view_by :content_id

  validates_present :name, :email, :body, :content_id
  #validates_format :error, :format => :email_address

  timestamps!
end
