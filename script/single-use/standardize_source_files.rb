require_relative "../../config/environment"

@counts = {}

def update_source_name source
  return unless source.name =~ /Page/
  source.update_attributes! name: source.name.gsub("Page", "Source"),
                            update_referers: true,
                            skip: :requirements
rescue => e
  tick :name_error, "problem renaming #{source.name}", e
end

def tick key, msg, e=nil
  @counts[key] ||= 0
  @counts[key] += 1
  msg = "ERROR: #{msg} :: #{e.message}" if e
  puts msg
  true
end

def valid_file source
  return unless source.file_card.file&.extension.present?
  tick :valid_file, "skipping #{source.name}: file looks fine"
end

def text_file source
  text_card = source.fetch trait: :text
  return unless text_card&.content.present?
  convert_text_to_file source, text_card.content
end

def convert_text_to_file source, text
  with_temp_text_file text do |file|
    source.file_card.update_attributes! file: file
    tick :text_success, "converted #{source.name} to text file"
  end
rescue => e
  tick :text_conversion_error, "problem converting #{source.name}", e
end

def with_temp_text_file text
  file = Tempfile.new "source.txt"
  file.write text
  yield file
ensure
  file.close
  file.unlink
end

def download source
  link = source.wikirate_link_card&.content
  return no_link(source) if !link.present?
  source.file_card.update_attributes! remote_file_url: link
  tick :download_success, "downloaded #{source.name}"
rescue => e
  tick :download_error, "problem downloading #{source.name}", e
end

def no_link source
  tick :no_link, "skipping #{source.name}: no link"
end

def standardize_file source
  %i[valid_file text_file download].each do |method|
    return if send method, source
  end
end

Card::Auth.as_bot do
  Card.where(type_id: Card::SourceID).find_each do |source|
    source.include_set_modules
    tick :sources, "processing #{source.name}"
    standardize_file source
    update_source_name source
    puts @counts
  end
end
