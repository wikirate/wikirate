require_relative "../../config/environment"

@counts = {}

def standardize_file source
  %i[valid_file text_file download].each do |method|
    break if send method, source
  end
end

# THE THREE MAIN OUTCOMES

# already have a valid file, move on...
def valid_file source
  return unless source.file_card.file&.extension.present?
  tick :valid_file, "skipping #{source.name}: file looks fine"
end

# have a +Text card.  convert it to a file
def text_file source
  text_card = source.fetch trait: :text
  return unless text_card&.content.present?
  convert_text_to_file source, text_card.content
end

# try to download file from web
def download source
  link = source.wikirate_link_card&.content
  return no_link(source) unless link.present?
  source.file_card.remote_file_url = link
  source.file_card.save!
  tick :download_success, "downloaded #{source.name}"
rescue => e
  tag source, "Bad Download"
  tick :download_error, "problem downloading #{source.name}", e
end

# THE HELP

def convert_text_to_file source, text
  with_temp_text_file text do |file|
    source.file_card.update_attributes! file: file
    tick :text_success, "converted #{source.name} to text file"
  end
rescue => e
  tag source, "Bad Text"
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

def no_link source
  tick :no_link, "skipping #{source.name}: no link"
end

# THE OTHER UPDATE

def update_source_name source
  return unless source.name.match?(/Page/)
  source.update_attributes! name: source.name.gsub("Page", "Source"),
                            update_referers: true,
                            skip: :requirements
rescue => e
  tick :name_error, "problem renaming #{source.name}", e
end

# THE (AC)COUNTING

def tick key, msg, e=nil
  @counts[key] ||= 0
  @counts[key] += 1
  msg = "ERROR: #{msg} :: #{e.message}" if e
  puts msg
  true
end

def tag source, tag
  tag_card = source.fetch trait: :wikirate_tag, new: { type_id: Card::PointerID }
  tag_card.add_item! tag
end

# THE CALLS

Card::Auth.as_bot do
  Card.where(type_id: Card::SourceID).find_each do |source|
    source.include_set_modules
    tick :sources, "processing #{source.name}"
    standardize_file source
    # update_source_name source
    puts @counts
  end
end
