# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.signin "Ethan McCutchen"

Card::Env.params = { compress: true, limit: 0 }
ENV["CACHE_JSON"] = "true"

def cached_dir
  File.join Card.config.paths["public"].existent, "cached"
end

def cached_file name, ext=:json, &block
  File.open File.join(cached_dir, "#{name}.#{ext}"), "w", &block
end

%i[wikirate_company metric wikirate_topic dataset].each do |codename|
  card = codename.card
  cached_file card.name.url_key do |f|
    f.write card.format(:json).show(:molecule, {})
  end
end
