require_relative "../../config/environment"
require "timeout"

@counts = {}

def standardize_file source
  with_timeout :standardize, 120 do
    %i[valid_file text_file download].each do |method|
      break if send method, source
    end
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
  update_file_card source, link
  tick :download_success, "SUCCESS: downloaded #{source.name}"
rescue => e
  tag source, "Bad Download"
  tick :download_error, "problem downloading #{source.name}", e
end

# THE OTHER UPDATE

def rename_source source
  return unless source.name.match?(/Page/)
  update_source_name source
rescue => e
  tick :name_error, "problem renaming #{source.name}", e
end

# THE HELP

# follow redirects
def get_final_url url
  result = Curl::Easy.perform(url) do |curl|
    curl.head = true
    curl.follow_location = true
  end
  result.last_effective_url
end

def update_file_card source, link
  file_card = source.file_card
  file_card.remote_file_url = get_final_url(link)
  file_card.save!
end

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

def update_source_name source
  with_timeout :rename, 60 do
    source.update_attributes! name: source.name.gsub("Page", "Source"),
                              update_referers: true,
                              skip: :requirements
  end
end

def with_timeout type, time
  Timeout.timeout(time) do
    yield
  end
rescue => e
  tick :"#{type}_timeout", "#{type} timed out", e
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
    # Card.where(name: "Page-000000032").find_each do |source|
    source.include_set_modules
    tick :sources, "processing #{source.name}"
    standardize_file source
    rename_source source
    puts @counts
  end
end
