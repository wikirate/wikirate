require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin "Ethan McCutchen"

Card::Env.params = { compress: true, limit: 0 }
Cardio.config.view_cache = false

ENV["CACHE_JSON"] = "true"

# TYPES_TO_CACHE = %i[company metric topic dataset].freeze
TYPES_TO_CACHE = %i[metric topic].freeze

def cached_dir
  File.join Card.config.paths["public"].existent, "cached"
end

def cached_file name, ext=:json, &block
  File.open File.join(cached_dir, "#{name}.#{ext}"), "w", &block
end

TYPES_TO_CACHE.each do |codename|
  card = codename.card
  cached_file card.name.url_key do |f|
    f.write card.format(:json).show(:molecule, {})
  end
end
