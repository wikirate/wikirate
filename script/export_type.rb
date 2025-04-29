require File.expand_path "../script_helper.rb", __FILE__

CARDTYPE = ARGV.shift

unless %w[company metric topic].include? CARDTYPE
  puts "USAGE: ruby ./script/export_type CARDTYPE # (metric, company, or topic)"
  exit CARDTYPE.nil? ? 0 : 1
end

Cardio.config.view_cache = false

def type_card
  CARDTYPE.to_sym.card
end

def json
  type_card.format(:json).render_all.to_s
end

def tmp_file
  f = Tempfile.new "deckorate_export.json"
  f.write json
  f.close
  yield f
ensure
  f.unlink
end

tmp_file do |file|
  type_card.fetch(:file, new: { type: :file }).update! file: file
end

exit 1
