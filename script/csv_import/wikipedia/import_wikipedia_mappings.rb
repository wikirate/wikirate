# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../config/environment"
require_relative "wikipedia_import_item"
require_relative "../csv_file"

#csv_path = File.expand_path "../data/error.csv", __FILE__
csv_path = File.expand_path "../data/wikirate_to_wikipedia.csv", __FILE__
Card::ImportCsv.new(csv_path, WikipediaImportItem)
       .import user: "Vasiliki Gkatziaki", error_policy: :report
