# Source-related helper methods for specs
module SourceHelper
  DEFAULT_SOURCE_URL = "http://www.google.com/?q=wikirate".freeze

  def create_source *args
    Card::Auth.as_bot { new_source(*args).tap(&:save!) }
  end

  def new_source file_or_url, fields: {}
    fields[:file] ||= source_file_args(file_or_url)
    Card.new type: :source, skip: :requirements, subfields: fields
  end

  private

  def source_file_args file_or_url
    file_or_url ||= DEFAULT_SOURCE_URL
    key = file_or_url.is_a?(String) ? :remote_file_url : :file
    { type: :file, key => file_or_url }
  end
end
