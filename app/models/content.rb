class Content < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!("mydb")

  property :type
  property :metadata
  property :data
  property :slug
  property :published
  

  view_by :slug
  view_by :type

  timestamps!
end