class ContentType < CouchRest::ExtendedDocument
  use_database CouchRest.database!("mydb")

  property :name
  property :fields

  view_by :name

  timestamps!
end