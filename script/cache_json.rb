#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin "Ethan McCutchen"

Card::Env.params[:limit] = 0

def cached_dir
  File.join Card.config.paths["public"].existent(), "cached"
end

def cached_file name, ext=:json, &block
  File.open File.join(cached_dir, "#{name}.#{ext}"), "w", &block
end

%i[wikirate_company metric wikirate_topic dataset].each do |codename|
  card = codename.card
  cached_file card.name do |f|
    f.write card.format(:json).render_molecule
  end
end
