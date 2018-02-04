#! no set module
#
# hash result for iframe checking
class MetaData
  attr_reader :title, :description, :image_url, :website, :error

  def initialize url
    @title = @description = @image_url = @website = @error = ""
    @url = url
    initialize_with_url
  end

  def initialize_with_url
    return error("empty url") if @url.blank?
    self.website = @url
    return error("invalid url") if @website.blank?
    if duplicates.any?
      data_from_card duplicates.first.left
    else
      data_from_url
    end
  end

  def duplicates
    @duplicates ||= Source.find_duplicates @url
  end

  def error msg
    @error = msg
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
    preview = LinkThumbnailer.generate @url
    @title = preview.title || ""
    @description = preview.description || ""
    @image_url = preview.images.first.src.to_s unless preview.images.empty?
  rescue LinkThumbnailer::Exceptions => e
    Rails.logger.debug "failed to fetch meta data with LinkThumbnailer: #{e.message}"
  end

  def fetch_field_content card, field
    Card[card, field]&.content || ""
  end
end
