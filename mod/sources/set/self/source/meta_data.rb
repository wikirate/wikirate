#! no set module
#
# hash result for iframe checking
class MetaData
  attr_reader :title, :description, :image_url, :website
  attr_accessor :error

  def initialize url
    @title = @description = @image_url = @website = @error = ""
    @url = url
    initialize_with_url
  end

  def initialize_with_url
    return self.error = "empty url" if @url.blank?
    self.website = @url
    return self.error = "invalid url" if @website.blank?
    if duplicates.any?
      data_from_card duplicates.first
    else
      data_from_url
    end
  end

  def duplicates
    @duplicates ||= Source.find_duplicates @url
  end

  def website= url
    @website = URI(url).host
  rescue URI::Error => e
    Rails.logger.debug "failed to fetch meta data because of bad url '#{url}': "\
                       "#{e.message}"
  end

  def data_from_card page_card
    @title = fetch_field_content page_card, "title"
    @description = fetch_field_content page_card, "description"
    @image_url = fetch_field_content page_card, "image_url"
  end

  def data_from_url
    return unless preview
    @title = preview.title || ""
    @description = preview.description || ""
    @image_url = preview.images.first.src.to_s unless preview.images.empty?
  end

  def preview
    @preview ||= Timeout.timeout(5) do
      LinkThumbnailer.generate @url
    end
  rescue LinkThumbnailer::Exceptions, Net::HTTPExceptions,
         Timeout::Error, URI::InvalidURIError => e
    Rails.logger.info "failed to extract metadata from #{@url}; #{e.message}"
    nil
  end

  def fetch_field_content card, field
    Card[card, field]&.content || ""
  end

  def to_json
    # I don't like this piece. The standard to_json return all instance variables
    # but we don't want @url and @duplicates in here.
    # There must be a better way
    { title: title, description: description, image_url: image_url, website: website,
      error: error }.to_json
  end
end
