# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../mod/csv_import/lib/import_item"

# import company wikipedia mappings
class WikipediaImportItem < ImportItem
  @columns = [:wikirate_id, :wikirate_name, :wikipedia_url]

  def normalize_wikirate_id val
    val.to_i
  end

  def validate_wikirate_id val
    Card[val]
  end

  def normalize_wikipedia_url val
    return val unless val =~ %r{/([^/]+)$}
    Regexp.last_match(1)
  end

  def import
    puts wikirate_name
    ensure_card [wikirate_id, :wikipedia],
                content: wikipedia_url,
                type_id: Card::PhraseID
  end
end
