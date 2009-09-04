class ContentField < CouchRest::ExtendedDocument
  use_database CouchRest.database!("mydb")

  property :name
  property :type
  property :display_name
  
end