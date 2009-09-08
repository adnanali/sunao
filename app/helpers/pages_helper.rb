module PagesHelper
  def rss_enclosure(file, attachment_name, attachment_attributes)
      {:url => file, :length => attachment_attributes['length'], :type => 'audio/mpeg'}
  end
end
