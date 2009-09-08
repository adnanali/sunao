# index.rss.builder
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Kuch Sunao"
    xml.description "Readings of poetry and prose."
    xml.link rss_url

    for article in @articles
      xml.item do
        xml.title article.title
        xml.description render(:partial => 'content/content.html.erb', :locals => {:content => article})
        xml.pubDate Time.parse(article.published_date).to_s(:rfc822)
        xml.link page_url(article.permalink)
        xml.guid page_url(article.permalink)
        unless article.reading_id.blank? 
          if article.reading['_attachments'] 
            article.reading['_attachments'].each do |attachment_name, attachment_attributes|
              xml.enclosure rss_enclosure(sound_file_url(:id => article.reading.slug, :filename => attachment_name), attachment_name, attachment_attributes)
            end
          end
        end
      end
    end
  end
end

