# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../../config/environment"
require_relative "open_corporates_import_item_compact"

csv_path = File.expand_path "../data/oc_mappings_vol1.csv", __FILE__

Card::ImportCsv.new(csv_path, OpenCorporatesImportItemCompact, col_sep: ";")
               .import user: "Philipp Kuehl", error_policy: :report
