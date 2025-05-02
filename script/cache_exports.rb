require File.expand_path "../script_helper.rb", __FILE__
Cardio.config.view_cache = false

def cache_export type
  puts "exporting #{type}".blue
  type_card = type.card
  tmp_file json(type_card) do |file|
    save_file_card type_card, file
  end
end

def json card
  card.format(:json).render_all
end

def tmp_file json
  f = Tempfile.new ["export", ".json"]
  f.write json
  f.close
  yield f
ensure
  f.unlink
end

def save_file_card type_card, file
  type_card.fetch(:file, new: { type: :file }).update! file: file
end

%i[topic metric company].each do |type|
  cache_export type
end

exit 1
