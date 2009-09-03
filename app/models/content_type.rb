class ContentType < CouchRest::ExtendedDocument
  use_database CouchRest.database!("mydb")

  property :type
  property :metadata
  property :data

  view_by :type

  timestamps!

  def to_param
    self.id
  end
end